import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'object.dart';
import 'types.dart';
import 'syncUser.dart';
import 'dart:collection';

typedef T ItemCreator<T>();

class Sort {
  Sort({this.sorted, this.ascending = true});
  final String? sorted;
  final bool ascending;
}

/// This class uses in swift libary as lazy array, but since we cannot use lazy list
/// we need to call list for translate objects into flutter
class Results<T extends RLMObject> {
  Results(this._channel, this._creator, this._syncUser, this._appId,
      this._partition);

  SyncUser get syncUser => _syncUser;
  String? query;
  int? _limit;
  List<Sort>? _sorted;

  String _appId;
  String _partition;
  SyncUser _syncUser;

  final MethodChannel _channel;
  final ItemCreator<T> _creator;

  // Observer properties
  StreamController<List<NotificationObject>>? _streamController;
  int uniqueListenerId = new Random().nextInt(1000000000);

  set limit(int limit) {
    _limit = limit;
  }

  set sorted(List<Sort> sorted) {
    _sorted = sorted;
  }

  /// Fetch list with given parameters.
  Future<List<T>> list<T>() async {
    assert(_partition.length != 0);

    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.objects.name, <String, dynamic>{
      'query': query,
      'limit': _limit,
      'sorted': _sorted?.sortArray(),
      'type': T.toString(),
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
    });

    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    List results = map["results"];
    return results.map<T>((map) => _creator().fromJson(map) as T).toList();
  }

  /// Fetch list with given parameters.
  Future<T> last<T>() async {
    assert(_partition.length != 0);

    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.objects.name, <String, dynamic>{
      'query': query,
      'limit': _limit,
      'sorted': _sorted == null ? null : _sorted!.sortArray(),
      'type': T.toString(),
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
    });

    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    List results = map["results"];
    return results.map<T>((map) => _creator().fromJson(map) as T).toList().last;
  }

  /// Get query result count
  Future<int?> count() async {
    assert(_partition.length != 0);

    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.count.name, <String, dynamic>{
      'query': query,
      'limit': _limit,
      'sorted': _sorted == null ? null : _sorted!.sortArray(),
      'type': T.toString(),
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
    });

    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    int? count = map["count"];
    return count;
  }

  Future<StreamController<List<NotificationObject>>?> subscribe() async {
    assert(_partition.length != 0);

    // Subscribe into manager
    NotificationManager manager = NotificationManager.instance(_channel)!;
    manager.addCallHandler(uniqueListenerId, this);

    var sorted = _sorted;
    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.subscribe.name, <String, dynamic>{
      'query': query,
      'limit': _limit,
      'listenId': uniqueListenerId,
      'sorted': sorted == null ? null : sorted.sortArray(),
      'type': T.toString(),
      'identity': _syncUser.identity,
      'appId': _appId,
      'partition': _partition,
    });
    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    _streamController = new StreamController<List<NotificationObject>>();
    return _streamController
        as FutureOr<StreamController<List<NotificationObject>>>;
  }

  Future<StreamController<List<NotificationObject>>?> watch(
      String database) async {
    assert(_partition.length != 0);

    // Subscribe into manager
    NotificationManager manager = NotificationManager.instance(_channel)!;
    manager.addCallHandler(uniqueListenerId, this);

    LinkedHashMap<dynamic, dynamic> map =
        await _channel.invokeMethod(Action.subscribe.name, <String, dynamic>{
      'listenId': uniqueListenerId,
      'collection': T.toString(),
      'database': database,
      'identity': _syncUser.identity,
      'appId': _appId,
    });
    if (map["error"] != null) {
      throw Exception("fetch list finished with exception ${map["error"]}");
    }

    _streamController = new StreamController<List<NotificationObject>>();
    return _streamController
        as FutureOr<StreamController<List<NotificationObject>>>;
  }

  unSubscribe() async {
    assert(_partition.length != 0);

    // Call to native method
    await _channel.invokeMethod(Action.unSubscribe.name, <String, dynamic>{
      'listenId': uniqueListenerId,
      'appId': _appId,
      'partition': _partition,
    });

    // Close stream
    _streamController!.close();

    // Remove subscription from manager
    NotificationManager manager = NotificationManager.instance(_channel)!;
    manager.removeCallHandler(uniqueListenerId);
  }

  Future notify(MethodCall call) async {
    List<NotificationObject> notificationObjects(
        List? maps, NotificationType type) {
      if (maps == null) {
        return <NotificationObject>[];
      }
      return maps.map((m) {
        int? index = m.keys.first;
        Map? contentData = m[index];
        T? object;
        if (contentData != null) {
          object = _creator().fromJson(contentData) as T?;
        }

        NotificationObject notificationObject =
            new NotificationObject(object, index, type);
        return notificationObject;
      }).toList();
    }

    List<NotificationObject> objects = <NotificationObject>[];

    List? insertions = call.arguments["insertions"];
    List? deletions = call.arguments["deletions"];
    List? modifications = call.arguments["modifications"];

    objects.addAll(notificationObjects(insertions, NotificationType.insert));
    objects.addAll(notificationObjects(deletions, NotificationType.delete));
    objects.addAll(notificationObjects(modifications, NotificationType.modify));

    _streamController!.add(objects);
  }
}

enum NotificationType { insert, delete, modify }

class NotificationObject<T> {
  final T object;
  final NotificationType type;
  final int? index;

  NotificationObject(this.object, this.index, this.type);
}

class NotificationManager {
  MethodChannel _channel;
  static NotificationManager? _instance;

  NotificationManager._privateConstructor(this._channel) {
    _channel.setMethodCallHandler(notify);
  }

  static NotificationManager? instance(MethodChannel channel) {
    if (_instance == null) {
      _instance = NotificationManager._privateConstructor(channel);
    }

    return _instance;
  }

  Map<int, Results?> _map = new Map();

  addCallHandler(int id, Results results) {
    _map[id] = results;
  }

  removeCallHandler(int id) {
    _map[id] = null;
  }

  Future notify(MethodCall call) async {
    int? id = call.arguments['id'];
    Results? result = _map[id!];
    if (result != null) {
      result.notify(call);
    }
  }
}

extension _SortAddition on List<Sort> {
  List<Map> sortArray() {
    List<Map> maps = <Map>[];
    for (Sort sort in this) {
      maps.add({"sorted": sort.sorted, 'ascending': sort.ascending});
    }

    return maps;
  }
}
