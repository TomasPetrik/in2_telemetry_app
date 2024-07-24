import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/user_with_represented_people.dart';
import 'package:scalesoft_app/data/tables/users.dart';
import 'package:scalesoft_app/utils/helpers/stream_helper.dart';

part 'users_dao.drift.dart';

@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Stream<UserWithRepresentedPeople?> getUser(int userId) {
    return _getUser((user) => user.id.equals(userId));
  }

  Stream<UserWithRepresentedPeople?> getUserByMuid(String muid) {
    return _getUser((user) => user.muid.equals(muid));
  }

  /// Deletes user with the given [userId], including its represented people, assigned devices, etc. (using cascades)
  Future<void> removeUser(int userId) async {
    await (delete(users)..where((user) => user.id.equals(userId))).go();
  }

  Future<void> removeUsers(Iterable<int> userIds) async {
    await (delete(users)..where((user) => user.id.isIn(userIds))).go();
  }

  Future<int> createUser(UsersCompanion user) async {
    final entity = await into(users).insertReturning(user, onConflict: DoUpdate((old) => user, target: []));

    return entity.id;
  }

  Future<void> removeObsoleteRepresentedPeople(int parentId, List<int> childrenToKeep) async {
    await (delete(users)..where((x) => x.parentId.equals(parentId) & x.id.isNotIn(childrenToKeep))).go();
  }

  Stream<List<UserWithRepresentedPeople>> getRootUsersFromHospital(int hospitalId) {
    return _getUsers((x) => x.hospitalId.equals(hospitalId) & x.parentId.isNull());
  }

  /// Gets all users, including represented people.
  Stream<List<UserWithRepresentedPeople>> getAll() {
    return _getUsers(null);
  }

  Stream<List<UserWithRepresentedPeople>> getAllRootUsers() {
    return _getUsers((x) => x.parentId.isNull());
  }

  Stream<List<UserWithRepresentedPeople>> getByIds(Iterable<int> ids) {
    return _getUsers((user) => user.id.isIn(ids));
  }

  Future<int> countUsers() async {
    final countExpression = users.id.count();

    final query = selectOnly(users)..addColumns([countExpression]);
    var result = await query.map((row) => row.read(countExpression)).getSingle();
    return result ?? 0;
  }

  Future<UserWithRepresentedPeople?> getLastUsedUser() async {
    final rootUser = await (select(users)
          ..orderBy([(user) => OrderingTerm(expression: user.lastActive, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
    if (rootUser == null) {
      return null;
    }

    final representedPeople = await (select(users)..where((x) => x.parentId.equals(rootUser.id))).get();

    return UserWithRepresentedPeople(rootUser: rootUser, representedPeople: representedPeople);
  }

  Future<User> updateUser(int userId, UsersCompanion changes) async {
    return (await (update(users)..where((user) => user.id.equals(userId))).writeReturning(changes)).first;
  }

  /// Returns all users matched using the provided [filter]. If [filter] is null, all users are returned.
  /// Every user that matches the [filter] contains **ALL** of their represented people - the [filter] is **NOT** applied when fetching child elements.
  Stream<List<UserWithRepresentedPeople>> _getUsers(Expression<bool> Function($UsersTable user)? filter) {
    final rootUsersQuery = select(users);

    if (filter != null) {
      rootUsersQuery.where(filter);
    }

    final rootUsersSubquery = Subquery(rootUsersQuery, 'rootUsers');

    final rootUsersStream = rootUsersQuery.watch();

    final representedPeopleStream = select(users)
        .join(
          [
            innerJoin(
              rootUsersSubquery,
              rootUsersSubquery.ref(users.id).equalsExp(users.parentId),
              useColumns: false,
            ),
          ],
        )
        .watch()
        .map(
          (list) => list.map((row) => row.readTable(users)),
        );

    final result =
        StreamHelper.combineLastValues(rootUsersStream, representedPeopleStream, (rootUsers, representedPeople) {
      return rootUsers.map((rootUser) {
        final matchingRepresentedPeople =
            representedPeople.where((representedPerson) => representedPerson.parentId == rootUser.id).toList();

        return UserWithRepresentedPeople(rootUser: rootUser, representedPeople: matchingRepresentedPeople);
      }).toList();
    });

    return result;
  }

  Stream<UserWithRepresentedPeople?> _getUser(Expression<bool> Function($UsersTable user) filter) {
    final result = _getUsers(filter).map((list) => list.singleOrNull);
    return result;
  }

  Future<UserWithRepresentedPeople?> getByAccessToken(String token) async {
    // We can't use json properties in sql queries directly
    final entities = await (select(users)..where((x) => x.authToken.contains(token))).get();

    // Make sure the match was actually in the access token
    final parent = entities.firstWhereOrNull((x) => x.authToken.accessToken == token && x.parentId == null);
    if (parent == null) {
      return null;
    }

    final representedPeople = entities.where((x) => x.parentId == parent.id).toList();

    return UserWithRepresentedPeople(rootUser: parent, representedPeople: representedPeople);
  }

  Future<User?> getByRefreshToken(String refreshToken) async {
    // We can't use json properties in sql queries directly
    final entities = await (select(users)..where((x) => x.authToken.contains(refreshToken))).get();

    // Make sure the match was actually in the refresh token
    final user = entities.firstWhereOrNull((x) => x.authToken.refreshToken == refreshToken && x.parentId == null);
    return user;
  }

  /// Applies the specified [changes] to a user with the given [userId], and to the user's represented people.
  Future<void> updateUserWithRepresentedPeople(int userId, UsersCompanion changes) async {
    await (update(users)..where((user) => user.id.equals(userId) | user.parentId.equals(userId))).write(changes);
  }
}
