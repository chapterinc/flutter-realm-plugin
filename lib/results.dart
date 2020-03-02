import 'package:flutter/services.dart';
import 'object.dart';
import 'types.dart';
import 'syncUser.dart';

typedef T ItemCreator<T>();

/// This class uses in swift libary as lazy array, but since we cannot use lazy list
/// we need to call list for translate objects into flutter
class Results<T extends RLMObject> {
  String _query;
  int _limit;
  SyncUser _syncUser;

  final MethodChannel _channel;
  final ItemCreator<T> _creator;

  Results(this._channel, this._creator, this._syncUser);

  set query(String query) {
    _query = query;
  }

  set limit(int limit) {
    _limit = limit;
  }

  /// Fetch list with given parameters.
  Future<List<T>> list() async {
    List<Map<String, dynamic>> maps =
        await _channel.invokeMethod(Action.objects.name, <String, dynamic>{
      'query': _query,
      'limit': _limit,
      'type': _runTimeType(),
      'identity': _syncUser.identity
    });

    return maps.map((map) => _creator().fromJson(map));
  }

  String _runTimeType() {
    return T.runtimeType.toString();
  }
}
