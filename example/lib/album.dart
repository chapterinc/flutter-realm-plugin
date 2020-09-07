import 'package:flutterrealm_light/object.dart';

enum AlbumType {
  none,
  date,
  thisWeek,
  nolocation,
  city,
  country,
  state,
  screenshot,
  text,
  trash,
  favorite,
  tag,
  people,
  celebrity,
  object,
  unsafe,
  shared,
}

class Album extends RLMObject {
  String id = '';
  String coverPhotoId;

  String name;
  String type;

  bool isSorted = false;

  int createdTimestamp;

  @override
  Album fromJson(Map json) {
    id = json['_id'];
    coverPhotoId = json['coverPhotoId'];

    isSorted = json['isSorted'];
    name = json['name'];
    type = json['type'];
    createdTimestamp = json['createdTimestamp'];

    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['_id'] = id;
    map['coverPhotoId'] = coverPhotoId;

    map['isSorted'] = isSorted;
    map['name'] = name;
    map['type'] = type;
    map['createdTimestamp'] = createdTimestamp;

    return map;
  }

  static Album newInstance() {
    Album album = Album();
    album.createdTimestamp = DateTime.now().millisecondsSinceEpoch;
    return album;
  }
}
