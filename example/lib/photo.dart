import 'package:flutterrealm_light/object.dart';
import 'album.dart';
import 'photo_detail.dart';

class Photo extends RLMObject {
  String id = '';
  String burstIdentifier;

  int type = 1;
  int subType = 0;
  String mediaType;

  bool isUploaded = false;
  bool isTrashed = false;
  bool isSorted = false;

  int userId;

  double duration;
  int pixelWidth;
  int pixelHeight;
  double startTime;
  double endTime;
  int timeScale;
  double latitude;
  double longitude;

  int year;
  int month;

  int createdDateTimestamp;
  int creationDateTimestamp;
  int sortedDateTimeStamp;
  int putBackDateTimeStamp;
  int modificationDate;

  PhotoDetail photoDetail;
  PhotoDetail userPhotoDetail;

  String state;
  String country;
  String city;

  var albums = List<Album>();

  @override
  Photo fromJson(Map json) {
    id = json['_id'];
    burstIdentifier = json['burstIdentifier'];

    int t = json['type'];
    if (t != null) {
      type = t;
    }

    int st = json['subType'];
    if (st != null) {
      subType = st;
    }
    mediaType = json['mediaType'];
    isUploaded = json['isUploaded'];
    isTrashed = json['isTrashed'];
    isSorted = json['isSorted'];
    userId = json['userId'];
    duration = json['duration'];
    pixelWidth = json['pixelWidth'];
    pixelHeight = json['pixelHeight'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    timeScale = json['timeScale'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    year = json['year'];
    month = json['month'];
    city = json['city'];
    country = json['country'];
    state = json['state'];
    createdDateTimestamp = json['createdDateTimestamp'];
    creationDateTimestamp = json['creationDateTimestamp'];
    sortedDateTimeStamp = json['sortedDateTimeStamp'];
    putBackDateTimeStamp = json['putBackDateTimeStamp'];
    modificationDate = json['modificationDate'];

    Map photoDetailMap = json['photoDetail'];
    if (photoDetailMap != null) {
      photoDetail = PhotoDetail().fromJson(photoDetailMap);
    }

    Map userPhotoDetailMap = json['userPhotoDetail'];
    if (userPhotoDetailMap != null) {
      userPhotoDetail = PhotoDetail().fromJson(userPhotoDetailMap);
    }

    List<dynamic> albums = json['albums'];
    if (albums != null) {
      this.albums = albums.map((map) => Album().fromJson(map)).toList();
    }

    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['_id'] = id;
    map['burstIdentifier'] = burstIdentifier;
    map['type'] = type;
    map['subType'] = subType;
    map['mediaType'] = mediaType;
    map['isUploaded'] = isUploaded;
    map['isTrashed'] = isTrashed;
    map['isSorted'] = isSorted;
    map['userId'] = userId;
    map['duration'] = duration;
    map['pixelWidth'] = pixelWidth;
    map['pixelHeight'] = pixelHeight;
    map['startTime'] = startTime;
    map['endTime'] = endTime;
    map['timeScale'] = timeScale;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['year'] = year;
    map['month'] = month;
    map['createdDateTimestamp'] = createdDateTimestamp;
    map['creationDateTimestamp'] = creationDateTimestamp;
    map['sortedDateTimeStamp'] = sortedDateTimeStamp;
    map['putBackDateTimeStamp'] = putBackDateTimeStamp;
    map['city'] = city;
    map['state'] = state;
    map['country'] = country;

    map['modificationDate'] = modificationDate;
    if (photoDetail != null) {
      map['photoDetail'] = photoDetail.toJson();
    }
    if (userPhotoDetail != null) {
      map['userPhotoDetail'] = userPhotoDetail.toJson();
    }
    if (albums != null) {
      map['albums'] = albums.map((album) => album.toJson()).toList();
    }
    return map;
  }

  @override
  bool operator ==(other) {
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
