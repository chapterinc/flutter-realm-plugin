import 'package:flutterrealm_light/object.dart';

class PhotoDetail extends RLMObject {
  String id = '';

  /// This parameters must be calculated relatively
  /// ``` centerx = realCenterx / containerWidth ```
  double centerx = 0;

  /// This parameters must be calculated relatively
  /// ``` centery = realCentery / containerHeight ```
  double centery = 0;

  double rotate = 0;
  double timestamp = 0;
  double zoom = 1;

  @override
  PhotoDetail fromJson(Map json) {
    id = json['_id'];

    centerx = json['centerx'];
    centery = json['centery'];
    rotate = json['rotate'];
    timestamp = json['timestamp'];
    zoom = json['zoom'];

    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['_id'] = id;
    map['centerx'] = centerx;
    map['centery'] = centery;
    map['rotate'] = rotate;
    map['timestamp'] = timestamp;
    map['zoom'] = zoom;
    return map;
  }
}