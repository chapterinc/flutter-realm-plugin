import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterrealm/realm.dart';
import 'package:flutterrealm/object.dart';
import 'package:flutterrealm/syncUser.dart';
import 'package:flutterrealm/results.dart';
import 'package:flutterrealm/types.dart';

import 'dart:collection';

void main() => runApp(MyApp());

class Photo extends RLMObject {
  String id = "";
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

  @override
  Map toJson() {
    Map map = super.toJson();
    map["id"] = id;
    map["burstIdentifier"] = burstIdentifier;
    map["type"] = type;
    map["subType"] = subType;
    map["mediaType"] = mediaType;
    map["isUploaded"] = isUploaded;
    map["isTrashed"] = isTrashed;
    map["isSorted"] = isSorted;
    map["userId"] = userId;
    map["duration"] = duration;
    map["pixelWidth"] = pixelWidth;
    map["pixelHeight"] = pixelHeight;
    map["startTime"] = startTime;
    map["endTime"] = endTime;
    map["timeScale"] = timeScale;
    map["year"] = year;
    map["month"] = month;
    map["createdDateTimestamp"] = createdDateTimestamp;
    map["creationDateTimestamp"] = creationDateTimestamp;
    map["modificationDate"] = modificationDate;
    return map;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _jwtString =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiJlR0pRbU11ZUtxV1pPRGJ4T1Fkb0czQUR1M3cxIiwiaXNBZG1pbiI6dHJ1ZSwiaWF0IjoxNTgyODk4NjkxfQ.P1asfb3nYdjNrUZIQ0OSEiiNh0N1inKVTdUcinrVXWGAnsOu-GRKWx-iuurzR0lvS-JsLK-GTg0WW1Vt1KNh0_v5xBlNVQsnrUQFgFKnoZpNQXuNGr9xDYj1QEeHhMz13xHJ0DCzutUZqDagMbL6GwxNikaPvz-VhNxzS9zPPXQQMa0pnIfE8SXfsAhj9r4Nwz8hPhqe_BoZg4nm8vA58bSF55Z0uEm34dfTWjGvLIz4SgTCKTKR7dJbRIiJxilSGmYka3ckLK9ZmwL1HaF9P6t34seECdK-6fjRNFtCFYeOKL8L-2GGuU3xyB32raq0fl-CbBt1dASCw-Kr_idczg';
  String _authenticationPath = 'http://5.188.160.116:9080';
  String _databasePath = 'realm://5.188.160.116:9080/~/database';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Check all users
    List<LinkedHashMap<String, SyncUser>> fetchAllUsers = await fetchAll();
    print("${fetchAllUsers.length}");
    SyncUser syncUser;

    if (fetchAllUsers.length == 0) {
      syncUser = await _login(_jwtString, _authenticationPath);
      print("${syncUser.identity}");
    } else {
      syncUser = fetchAllUsers[0].values.first;
    }

    Photo photo = await _createPhoto(syncUser);
    print("Photo id: ${photo.id}");

    List<Photo> photos = await _getPhotos(syncUser);
    print("Photos count: ${photos.length}");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }

  Future<List<LinkedHashMap<String, SyncUser>>> fetchAll() async {
    List<LinkedHashMap<String, SyncUser>> users = await Realm.all();
    return users;
  }

  Future<SyncUser> _login(String jwt, String server) async {
    SyncCredentials syncCredentials =
        SyncCredentials(jwt, SyncCredentialsType.jwt);
    SyncUser user =
        await SyncUser.login(credentials: syncCredentials, server: server);

    assert(user != null);
    return user;
  }


  Future<Photo> _createPhoto(SyncUser syncUser) async {
    Photo photo = Photo();
    photo.id = "12398234";

    Realm realm = Realm(syncUser, _databasePath);

    Photo createdPhoto = await realm.create<Photo>(() {
      return new Photo();
    }, photo, policy: UpdatePolicy.all);

    return createdPhoto;
  }

  Future<List<Photo>> _getPhotos(SyncUser syncUser) async {
    Realm realm = Realm(syncUser, _databasePath);

    Results photoResult = realm.objects<Photo>(() {
      return new Photo();
    });
    List<Photo> photos = await photoResult.list();

    return photos;
  }
}
