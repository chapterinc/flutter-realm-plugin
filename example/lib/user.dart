import 'dart:core';

import 'package:flutterrealm_light/object.dart';

import 'photo.dart';

class User extends RLMObject {
  String id = '';
  String password = '';
  String username = '';

  String? email;
  String? phone;

  String? countryCode;
  String? emoji;
  String? firstName;
  String? surname;

  int? birthDayTimestamp;
  int? createdDateTimestamp;
  int? recentsSortedDateTimestamp;
  int? recentsNewPhotoDateTimestamp;

  int recentsPhotosSortedPartsCount = 0;
  int totalMediaSortedCount = 0;
  int totalMediaCount = 0;
  int totalMediaKept = 0;
  int albumsCount = 0;
  double keptPercent = 0;
  double sortedPercent = 0;

  bool isMe = true;

  Photo? photo;

  @override
  User fromJson(Map json) {
    id = json['id'];
    password = json['password'];
    username = json['username'];

    email = json['email'];
    phone = json['phone'];

    countryCode = json['countryCode'];
    emoji = json['emoji'];
    firstName = json['firstName'];
    surname = json['surname'];

    birthDayTimestamp = json['birthDayTimestamp'];
    createdDateTimestamp = json['createdDateTimestamp'];
    recentsSortedDateTimestamp = json['recentsSortedDateTimestamp'];
    recentsNewPhotoDateTimestamp = json['recentsNewPhotoDateTimestamp'];

    recentsPhotosSortedPartsCount = json['recentsPhotosSortedPartsCount'];
    totalMediaSortedCount = json['totalMediaSortedCount'];
    totalMediaCount = json['totalMediaCount'];
    totalMediaKept = json['totalMediaKept'];
    albumsCount = json['albumsCount'];
    keptPercent = json['keptPercent'];
    sortedPercent = json['sortedPercent'];

    isMe = json['isMe'];

    Map photoMap = json['photo'];
    if (photoMap != null) {
      photo = Photo().fromJson(photoMap);
    }

    return this;
  }

  @override
  Map toJson() {
    Map map = super.toJson();
    map['id'] = id;
    map['password'] = password;
    map['username'] = username;

    map['email'] = email;
    map['countryCode'] = countryCode;
    map['emoji'] = emoji;
    map['firstName'] = firstName;
    map['surname'] = surname;

    map['birthDayTimestamp'] = birthDayTimestamp;
    map['createdDateTimestamp'] = createdDateTimestamp;
    map['recentsSortedDateTimestamp'] = recentsSortedDateTimestamp;
    map['recentsNewPhotoDateTimestamp'] = recentsNewPhotoDateTimestamp;

    map['recentsPhotosSortedPartsCount'] = recentsPhotosSortedPartsCount;
    map['totalMediaSortedCount'] = totalMediaSortedCount;
    map['totalMediaCount'] = totalMediaCount;
    map['totalMediaKept'] = totalMediaKept;
    map['albumsCount'] = albumsCount;
    map['keptPercent'] = keptPercent;
    map['sortedPercent'] = sortedPercent;

    map['isMe'] = isMe;

    if (photo != null) {
      map['photo'] = photo?.toJson();
    }

    return map;
  }
}

