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
  static const MethodChannel _channel =
      const MethodChannel('flutterrealm_light');
  SyncUser _syncUser;
  String _databaseUrl;

  Realm(this._syncUser, this._databaseUrl) : assert(_channel != null);

  /// Fetch list of objects.
  ///
  /// [param] _creator required for make object for given generic type
  Results objects<T extends RLMObject>(ItemCreator _creator) {
    return Results<T>(_channel, _creator, _syncUser, _databaseUrl);
  }

  /// Create object by given policy.
  ///
  /// [param] _creator required for make object for given generic type
  Future<T> create<T extends RLMObject>(ItemCreator _creator, T value,
      {UpdatePolicy policy = UpdatePolicy.error}) async {
    Map<String, dynamic> values = {
      'value': value.toJson(),
      'policy': policy.value,
      'identity': _syncUser.identity,
      'databaseUrl': _databaseUrl,
      "type": T.toString()
    };
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.create.name, values);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return _creator().fromJson(map);
  }

  static Future<List<LinkedHashMap<String, SyncUser>>> all() async {
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.allUsers.name);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }
    List<dynamic> userKeyDictionaries = map["results"];
    List linkedHashMaps = List<LinkedHashMap<String, SyncUser>>();
    linkedHashMaps = userKeyDictionaries.map((value) {
      LinkedHashMap<String, SyncUser> linkedHashMap = new LinkedHashMap();
      LinkedHashMap<dynamic, dynamic> map = value;
      if (map.keys.length > 0) {
        linkedHashMap[map.keys.first] = SyncUser.fromMap(map[map.keys.first]);
      }

      return linkedHashMap;
    }).toList();

    return linkedHashMaps;
  }

  /// Delete object from primaryKey.
  Future<void> delete<T extends RLMObject>(dynamic primaryKey) async {
    Map<String, dynamic> values = {
      'primaryKey': primaryKey,
      'identity': _syncUser.identity,
      'databaseUrl': _databaseUrl,
      "type": T.toString()
    };
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.delete.name, values);

    if (map["error"] != null) {
      throw Exception("create object finished with exception ${map["error"]}");
    }

    return;
  }
}
