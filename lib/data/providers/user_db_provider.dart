import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:scalesoft_app/api/contracts/device/device_instruction_contract.dart';
import 'package:scalesoft_app/api/contracts/device/device_prototype_contract.dart';
import 'package:scalesoft_app/api/contracts/time_settings/time_setting_contract.dart';
import 'package:scalesoft_app/api/contracts/user/current_user_info_contract.dart';
import 'package:scalesoft_app/api/contracts/user/user_contract.dart';
import 'package:scalesoft_app/data/app_database.dart';
import 'package:scalesoft_app/data/entities/combined_entities/user_with_represented_people.dart';
import 'package:scalesoft_app/data/entities/json_entities/care_plan/time_only.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/auth_token.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/measurement_thresholds.dart';
import 'package:scalesoft_app/data/entities/json_entities/user/time_setting.dart';
import 'package:scalesoft_app/data/providers/device_db_provider.dart';
import 'package:scalesoft_app/data/providers/device_prototype_db_provider.dart';
import 'package:scalesoft_app/data/providers/device_instruction_db_provider.dart';
import 'package:scalesoft_app/mapper/thresholds_mapper.dart';
import 'package:scalesoft_app/mapper/user_mapper.dart';
import 'package:scalesoft_app/mapper/when_code_mapper.dart';
import 'package:scalesoft_app/model/enum/user_problem_type.dart';
import 'package:scalesoft_app/model/user_model.dart';

@injectable
class UserDbProvider {
  final AppDatabase _database;
  final UserMapper _userMapper;
  final WhenCodeMapper _whenCodeMapper;
  final ThresholdsMapper _thresholdsMapper;
  final DeviceDbProvider _deviceDbProvider;
  final DevicePrototypeDbProvider _devicePrototypeDbProvider;
  final DeviceInstructionDbProvider _deviceInstructionDbProvider;

  UserDbProvider(
    this._database,
    this._userMapper,
    this._whenCodeMapper,
    this._thresholdsMapper,
    this._deviceDbProvider,
    this._devicePrototypeDbProvider,
    this._deviceInstructionDbProvider,
  );

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

    MeasurementThresholds? thresholds = _thresholdsMapper.tryConvert(rootUser.measurementThresholds);

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
      thresholds: Value(thresholds),
    );

    final userId = await _database.usersDao.createUser(rootUserCompanion);

    final List<int> representedPeopleIds = [];

    for (final representedPerson in representedPeople ?? []) {
      MeasurementThresholds? thresholds = _thresholdsMapper.tryConvert(representedPerson.measurementThresholds);

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
        thresholds: Value(thresholds),
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

  /// Updates the user with the given [userId] and their represented people using the changes from [contract] and [timeSettingContracts].
  /// Saves [deviceModels] for the root user and all represented people.
  ///
  /// All changes from [contract] will be applied - including assigned devices.
  Future<void> updateUserFromContract(
    int userId,
    CurrentUserInfoContract contract,
    List<TimeSettingContract> timeSettingContracts,
    List<DevicePrototypeContract> deviceModels,
    List<DeviceInstructionContract> deviceInstructions
  ) async {
    final rootUser = contract.currentUser;
    MeasurementThresholds? thresholds = _thresholdsMapper.tryConvert(rootUser.measurementThresholds);
    final timeSettings = timeSettingContracts
        .where((x) => x.userMuid == contract.currentUser.muid)
        .map(
          (x) => TimeSetting(
            code: _whenCodeMapper.convert(x.code),
            start: TimeOnly.fromString(x.start),
            end: TimeOnly.fromString(x.end),
          ),
        )
        .toList();

    final changes = UsersCompanion(
      firstNames: Value(rootUser.firstNames.join(' ')),
      lastNames: Value(rootUser.lastNames.join(' ')),
      phoneNumbers: Value(rootUser.phoneNumbers ?? []),
      emailAddresses: Value(rootUser.emailAddresses ?? []),
      thresholds: Value(thresholds),
      timeSettings: Value(timeSettings),
    );

    await _devicePrototypeDbProvider.replaceUserPrototypes(userId, deviceModels);
    final updatedUser = await _database.usersDao.updateUser(userId, changes);
    await _deviceDbProvider.updateUserDevices(userId, contract.assignedDevices ?? []);
    await _deviceInstructionDbProvider.replaceDeviceInstructions(deviceInstructions);

    await updateRepresentedPeople(updatedUser, contract.representedPeople ?? [], timeSettingContracts, deviceModels);
  }

  Future<void> updateRepresentedPeople(
    User parent,
    List<UserContract> updatedRepresentedPeople,
    List<TimeSettingContract> timeSettingContracts,
    List<DevicePrototypeContract> deviceModels,
  ) async {
    final existingRepresentedPeople = (await _database.usersDao.getUser(parent.id).first)?.representedPeople ?? [];
    final usersToRemove = existingRepresentedPeople
        .where((existing) => updatedRepresentedPeople.none((x) => x.muid == existing.muid))
        .map((x) => x.id);

    await _database.usersDao.removeUsers(usersToRemove);

    final now = DateTime.now();

    for (final person in updatedRepresentedPeople) {
      int personId;

      MeasurementThresholds? thresholds = _thresholdsMapper.tryConvert(person.measurementThresholds);

      final timeSettings = timeSettingContracts
          .where((x) => x.userMuid == person.muid)
          .map(
            (x) => TimeSetting(
              code: _whenCodeMapper.convert(x.code),
              start: TimeOnly.fromString(x.start),
              end: TimeOnly.fromString(x.end),
            ),
          )
          .toList();

      final existingPerson = existingRepresentedPeople.firstWhereOrNull((x) => x.muid == person.muid);
      if (existingPerson == null) {
        final companion = UsersCompanion.insert(
          parentId: Value(parent.id),
          hospitalId: parent.hospitalId,
          muid: person.muid,
          firstNames: person.firstNames.join(' '),
          lastNames: person.lastNames.join(' '),
          authToken: parent.authToken,
          lastSyncAt: now,
          timeSettings: timeSettings,
          permissions: parent.permissions,
          phoneNumbers: person.phoneNumbers ?? [],
          emailAddresses: person.emailAddresses ?? [],
          thresholds: Value(thresholds),
        );

        personId = await _database.usersDao.createUser(companion);
      } else {
        final companion = UsersCompanion(
          firstNames: Value(person.firstNames.join(' ')),
          lastNames: Value(person.lastNames.join(' ')),
          lastSyncAt: Value(now),
          phoneNumbers: Value(person.phoneNumbers ?? []),
          emailAddresses: Value(person.emailAddresses ?? []),
          thresholds: Value(thresholds),
          timeSettings: Value(timeSettings),
        );
        await _database.usersDao.updateUser(existingPerson.id, companion);

        personId = existingPerson.id;
      }

      await _devicePrototypeDbProvider.replaceUserPrototypes(personId, deviceModels);
      await _deviceDbProvider.updateUserDevices(personId, person.assignedDevices ?? []);
    }
  }
}
