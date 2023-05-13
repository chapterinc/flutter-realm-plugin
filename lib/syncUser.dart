import 'dart:async';

import 'package:flutter/services.dart';
import 'types.dart';

class SyncUser {
  static const MethodChannel _channel =
      const MethodChannel('flutterrealm_light');

  late String _identity;
  late String _appId;
  late String _id;

  /// partition can be changed in specific cases
  late String partition;

  String get identity {
    return _identity;
  }

  String get id {
    return _id;
  }

  static Future<SyncUser> login(
      {credentials: SyncCredentials, appId: String}) async {
    Map<dynamic, dynamic> syncUserMap = await _channel.invokeMethod(
        Action.login.name,
        <String, dynamic>{'appId': appId, 'jwt': credentials.jwt});
    syncUserMap["appId"] = appId;
    syncUserMap["partition"] = syncUserMap["identity"];
    return SyncUser.fromMap(syncUserMap);
  }

  static SyncUser fromMap(Map map) {
    SyncUser syncUser = SyncUser();
    syncUser._identity = map["identity"];
    syncUser._appId = map["appId"];
    syncUser.partition = map["partition"];
    syncUser._id = map["id"];

    return syncUser;
  }

  Future<void> asyncOpen() async {
    assert(partition.length != 0);

    Map<dynamic, dynamic> map = await _channel.invokeMethod(
        Action.asyncOpen.name, <String, dynamic>{
      'identity': _identity,
      'appId': _appId,
      'partition': partition
    });
    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return;
  }

  Future<void> logout() async {
    assert(partition.length != 0);

    Map<dynamic, dynamic> map = await _channel.invokeMethod(
        Action.logout.name, <String, dynamic>{
      'identity': _identity,
      'appId': _appId,
      'partition': partition
    });
    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return;
  }
}

enum SyncCredentialsType { jwt }

class SyncCredentials {
  String _jwt;

  get jwt => _jwt;

  SyncCredentials(this._jwt);

  Map toMap() {
    Map map = Map();
    map["jwt"] = _jwt;

    return map;
  }
}
