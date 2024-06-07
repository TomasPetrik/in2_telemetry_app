import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/user/user_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/user_with_represented_people.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';
import 'package:scalesoft_app/mapper/user_mapper.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.dart';
import 'package:scalesoft_app/model/enum/user_problem_type.dart';
import 'package:scalesoft_app/model/user_model.dart';

@injectable
class UserDbProvider {
  final AppDatabase _database;
  final UserMapper _userMapper;
  final WhenCodeMapper _whenCodeMapper;

  UserDbProvider(this._database, this._userMapper, this._whenCodeMapper);

  Stream<UserModel?> get(int userId) {
    final entity = _database.usersDao.getUser(userId);

    return entity.map((x) => x == null ? null : _mapUser(x));
  }

  Stream<UserModel?> getByMuid(String muid) {
    final stream = _database.usersDao.getUserByMuid(muid);

    return stream.map((x) => x == null ? null : _mapUser(x));
  }

  /// Saves the given user with represented people. If the user already exists, represented people not in [representedPeople] will be deleted.
  Future<int> createOrUpdateUser(
    UserContract rootUser,
    List<UserContract>? representedPeople,
    int hospitalId,
    AuthToken authToken,
    List<String> permissions,
    List<TimeSettingContract> timeSettingContracts,
  ) async {
    final timeSettings = timeSettingContracts
        .map(
          (x) => TimeSetting(
            code: _whenCodeMapper.convert(x.code),
            start: TimeOnly.fromString(x.start),
            end: TimeOnly.fromString(x.end),
          ),
        )
        .toList();

    final now = DateTime.now();

    final rootUserCompanion = UsersCompanion.insert(
      hospitalId: hospitalId,
      muid: rootUser.muid,
      firstNames: rootUser.firstNames.join(' '),
      lastNames: rootUser.lastNames.join(' '),
      authToken: authToken,
      lastSyncAt: now,
      lastActive: Value(now),
      timeSettings: timeSettings,
      permissions: permissions,
      phoneNumbers: rootUser.phoneNumbers ?? [],
      emailAddresses: rootUser.emailAddresses ?? [],
    );

    final userId = await _database.usersDao.createUser(rootUserCompanion);

    final List<int> representedPeopleIds = [];

    for (final representedPerson in representedPeople ?? []) {
      final companion = UsersCompanion.insert(
        parentId: Value(userId),
        hospitalId: hospitalId,
        muid: representedPerson.muid,
        firstNames: representedPerson.firstNames.join(' '),
        lastNames: representedPerson.lastNames.join(' '),
        authToken: authToken,
        lastSyncAt: now,
        timeSettings: timeSettings,
        permissions: permissions,
        phoneNumbers: representedPerson.phoneNumbers ?? [],
        emailAddresses: representedPerson.emailAddresses ?? [],
      );

      final id = await _database.usersDao.createUser(companion);
      representedPeopleIds.add(id);
    }

    await _database.usersDao.removeObsoleteRepresentedPeople(userId, representedPeopleIds);

    return userId;
  }

  Future<UserModel?> getLastUsedUser() async {
    final entity = await _database.usersDao.getLastUsedUser();
    if (entity == null) {
      return null;
    }

    return _mapUser(entity);
  }

  Future<UserModel?> getByAccessToken(String token) async {
    final entity = await _database.usersDao.getByAccessToken(token);
    if (entity == null) {
      return null;
    }

    return _mapUser(entity);
  }

  /// Updates auth token and permissions of a user and their represented people
  Future<void> updateAuthParameters(int userId, AuthToken token, List<String> permissions) async {
    final changes = UsersCompanion(authToken: Value(token), permissions: Value(permissions));
    await _database.usersDao.updateUserWithRepresentedPeople(userId, changes);
  }

  Stream<List<UserModel>> getAll() {
    final entities = _database.usersDao.getAll();

    final result = entities.asyncMap(_mapUsers);
    return result;
  }

  Stream<List<UserModel>> getAllRootUsers() {
    final entities = _database.usersDao.getAllRootUsers();

    final result = entities.asyncMap(_mapUsers);
    return result;
  }

  Stream<List<UserModel>> getByIds(Iterable<int> userIds) {
    final entities = _database.usersDao.getByIds(userIds);

    final result = entities.asyncMap(_mapUsers);
    return result;
  }

  /// Deletes the user with the given [userId], including represented people, measurements, etc (using db cascades)
  Future<void> remove(int userId) async {
    await _database.usersDao.removeUser(userId);
  }

  Future<List<UserModel>> _mapUsers(Iterable<UserWithRepresentedPeople> entities) async {
    final result = entities.map(_mapUser).toList();

    for (final user in [...result, ...result.expand((x) => x.representedPeople)]) {
      final problem = await getProblemIfExists(user);
      user.problem = problem;
    }

    return result;
  }

  Future<UserProblemType?> getProblemIfExists(UserModel user) async {
    if (user.isSessionExpired) {
      return UserProblemType.sessionExpired;
    }

    if (user.lastSyncFailed) {
      return UserProblemType.lastSyncFailed;
    }

    final changedPlans = await _database.carePlansDao.getChangedPlans([user.id]);
    if (changedPlans.isNotEmpty) {
      return UserProblemType.carePlanUpdated;
    }

    final pendingResults = await _database.measurementsDao.getByUser(user.id, null, null, null, false);

    if (pendingResults.isNotEmpty) {
      return UserProblemType.syncResultsFailed;
    }

    return null;
  }

  UserModel _mapUser(UserWithRepresentedPeople entity) {
    final UserModel rootUser = _userMapper.convert(entity.rootUser);
    final List<UserModel> representedPeople = _userMapper.convertList(entity.representedPeople);

    rootUser.representedPeople = representedPeople;
    return rootUser;
  }

  Future<void> setExpiredByRefreshToken(String refreshToken) async {
    final user = await _database.usersDao.getByRefreshToken(refreshToken);
    if (user == null) {
      return;
    }

    await _database.usersDao.updateUser(user.id, const UsersCompanion(isSessionExpired: Value(true)));
  }

  Future<int> countUsers() async {
    return await _database.usersDao.countUsers();
  }

  Future<void> updateUser(int userId, UsersCompanion changes) async {
    await _database.usersDao.updateUser(userId, changes);
  }
}
