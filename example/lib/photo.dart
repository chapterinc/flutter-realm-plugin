import 'package:flutterrealm_light/object.dart';

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

  String userId;

  double duration;
  int pixelWidth;
  int pixelHeight;
  double startTime;
  double endTime;
  int timeScale;

  int year;
  int month;

  int createdDateTimestamp;
  int creationDateTimestamp;
  int sortedDateTimeStamp;
  int modificationDate;

  PhotoDetail photoDetail;
  PhotoDetail userPhotoDetail;

  @override
  Photo fromJson(Map json) {
    id = json['id'];
    burstIdentifier = json['burstIdentifier'];

    type = json['type'];
    subType = json['subType'];
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
    year = json['year'];
    month = json['month'];
    createdDateTimestamp = json['createdDateTimestamp'];
    creationDateTimestamp = json['creationDateTimestamp'];
    sortedDateTimeStamp = json['sortedDateTimeStamp'];
    modificationDate = json['modificationDate'];

    Map photoDetailMap = json['photoDetail'];
    if (photoDetailMap != null) {
      photoDetail = PhotoDetail().fromJson(photoDetailMap);
    }

    Map userPhotoDetailMap = json['userPhotoDetail'];
    if (userPhotoDetailMap != null) {
      userPhotoDetail = PhotoDetail().fromJson(userPhotoDetailMap);
    }

    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['id'] = id;
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
    map['year'] = year;
    map['month'] = month;
    map['createdDateTimestamp'] = createdDateTimestamp;
    map['creationDateTimestamp'] = creationDateTimestamp;
    map['modificationDate'] = modificationDate;
    if (photoDetail != null) {
      map['photoDetail'] = photoDetail.toJson();
    }
    if (userPhotoDetail != null) {
      map['userPhotoDetail'] = userPhotoDetail.toJson();
    }
    return map;
  }

  @override
  bool operator == (other) {
    return id == other.id;
  }
}

