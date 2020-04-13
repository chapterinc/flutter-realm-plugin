import 'package:flutterrealm_light/object.dart';

class Album extends RLMObject {
  String id = '';
  String coverPhotoId;

  String name;
  String flag;
  String type;
  String tag;

  bool isSorted = false;
  bool isTrash = false;
  bool isFavorite = false;
  bool isFake = false;

  int createdTimestamp;
  int timestamp;

  @override
  Album fromJson(Map json) {
    id = json['id'];
    coverPhotoId = json['coverPhotoId'];

    isSorted = json['isSorted'];
    isTrash = json['isTrash'];
    isFavorite = json['isFavorite'];
    isFake = json['isFake'];
    name = json['name'];
    flag = json['flag'];
    type = json['type'];
    tag = json['tag'];
    createdTimestamp = json['createdTimestamp'];
    timestamp = json['timestamp'];
    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['id'] = id;
    map['coverPhotoId'] = coverPhotoId;

    map['isSorted'] = isSorted;
    map['isTrash'] = isTrash;
    map['isFavorite'] = isFavorite;
    map['isFake'] = isFake;
    map['name'] = name;
    map['flag'] = flag;
    map['type'] = type;
    map['tag'] = tag;
    map['createdTimestamp'] = createdTimestamp;
    map['timestamp'] = timestamp;

    return map;
  }
}
