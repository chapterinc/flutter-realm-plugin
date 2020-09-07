import 'dart:collection';

import 'package:flutter/services.dart';
import 'types.dart';

class SyncUser {
  static const MethodChannel _channel =
      const MethodChannel('flutterrealm_light');

  String _identity;
  String _appId;
  String _partition;

  String get identity {
    return _identity;
  }

  static Future<SyncUser> login(
      {credentials: SyncCredentials, appId: String, partition: String}) async {
    LinkedHashMap<dynamic, dynamic> syncUserMap = await _channel.invokeMethod(
        Action.login.name,
        <String, dynamic>{'appId': appId, 'jwt': credentials.jwt});
    syncUserMap["appId"] = appId;
    syncUserMap["partition"] = partition;
    return SyncUser.fromMap(syncUserMap);
  }

  static SyncUser fromMap(Map map) {
    SyncUser syncUser = SyncUser();
    syncUser._identity = map["identity"];
    syncUser._appId = map["appId"];
    syncUser._partition = map["partition"];

    return syncUser;
  }

  Future<void> logout({credentials: SyncCredentials}) async {
    LinkedHashMap<dynamic, dynamic> map = await _channel.invokeMethod(
        Action.logout.name, <String, dynamic>{
      'identity': _identity,
      'appId': _appId,
      'partition': _partition
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
  SyncCredentialsType _type;

  get jwt => _jwt;

  SyncCredentials(this._jwt, this._type);

  Map toMap() {
    Map map = Map();
    map["jwt"] = _jwt;

    return map;
  }
}
