import 'package:flutter/services.dart';
import 'object.dart';
import 'types.dart';
import 'syncUser.dart';
import 'dart:collection';

typedef T ItemCreator<T>();

/// This class uses in swift libary as lazy array, but since we cannot use lazy list
/// we need to call list for translate objects into flutter
class Results<T extends RLMObject> {
  String _query;
  String _databaseUrl;
  int _limit;
  SyncUser _syncUser;

  final MethodChannel _channel;
  final ItemCreator<T> _creator;

  Results(this._channel, this._creator, this._syncUser, this._databaseUrl);

  set query(String query) {
    _query = query;
  }

  set limit(int limit) {
    _limit = limit;
  }

  /// Fetch list with given parameters.
  Future<List<T>> list() async {
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.objects.name, <String, dynamic>{
      'query': _query,
      'limit': _limit,
      'type': T.toString(),
      'identity': _syncUser.identity,
      'databaseUrl': _databaseUrl,
    });

    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    List results = map["results"];
    return results.map<T>((map) => _creator().fromJson(map)).toList();
  }

  String _runTimeType() {
    return T.runtimeType.toString();
  }
}
