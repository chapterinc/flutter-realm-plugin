import 'dart:async';
import 'dart:collection';

import 'package:flutter/services.dart';
import 'results.dart';
import 'object.dart';
import 'types.dart';
import 'syncUser.dart';

/// For interaction with realm
///
/// [param] _channel required for make call to native library
class Realm {
  Realm(this._syncUser, this._appId, this._partition);

  SyncUser get syncUser => _syncUser;
  String get appId => _appId;
  String get partition => _partition;

  static const MethodChannel _channel =
      const MethodChannel('flutterrealm_light');

  SyncUser _syncUser;
  String _appId;
  String _partition;

  /// Fetch list of objects.
  ///
  /// [param] _creator required for make object for given generic type
  Results<T> objects<T extends RLMObject>(ItemCreator _creator) {
    return Results<T>(
        _channel, _creator as T Function(), _syncUser, _appId, _partition);
  }

  /// Create object by given policy.
  ///
  /// [param] _creator required for make object for given generic type
  Future<T> create<T extends RLMObject>(ItemCreator _creator, T value,
      {UpdatePolicy policy = UpdatePolicy.error}) async {
    return createWithJson(_creator, value.toJson(), policy: policy);
  }

  /// Create object by given policy.
  ///
  /// [param] _creator required for make object for given generic type
  Future<T> createWithJson<T extends RLMObject>(ItemCreator _creator, Map value,
      {UpdatePolicy policy = UpdatePolicy.error}) async {
    assert(_partition.length != 0);

    Map<String, dynamic> values = {
      'value': value,
      'policy': policy.value,
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
      "type": T.toString()
    };
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.create.name, values);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return _creator().fromJson(map);
  }

  static Future<List<LinkedHashMap<String, SyncUser>>> all(String appId) async {
    Map<String, dynamic> values = {
      'appId': appId,
    };

    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.allUsers.name, values);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }
    List<dynamic> userKeyDictionaries = map["results"];
    var linkedHashMaps = <LinkedHashMap<String, SyncUser>>[];
    linkedHashMaps = userKeyDictionaries.map((value) {
      LinkedHashMap<String, SyncUser> linkedHashMap = new LinkedHashMap();
      LinkedHashMap<dynamic, dynamic> map = value;
      if (map.keys.length > 0) {
        Map m = map[map.keys.first];
        m['appId'] = appId;
        m['partition'] = m['id'];
        linkedHashMap[map.keys.first] = SyncUser.fromMap(m);
      }

      return linkedHashMap;
    }).toList();

    return linkedHashMaps;
  }

  /// Logout all users
  static Future<void> logoutAll(String appId) async {
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.logoutAll.name, <String, dynamic>{
      'appId': appId,
    });
    if (map["error"] != null) {
      throw Exception("problem on logout ${map["error"]}");
    }

    return;
  }

  /// Delete object from primaryKey.
  Future<void> delete<T extends RLMObject>(dynamic primaryKey) async {
    assert(_partition.length != 0);

    Map<String, dynamic> values = {
      'primaryKey': primaryKey,
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
      "type": T.toString()
    };
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.delete.name, values);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return;
  }

  /// Delete all objects from realm.
  Future<void> deleteAll() async {
    assert(_partition.length != 0);

    Map<String, dynamic> values = {
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition
    };
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.deleteAll.name, values);

    if (map["error"] != null) {
      throw Exception("deleteall finished with exception ${map["error"]}");
    }

    return;
  }
}
