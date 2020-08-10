import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterrealm_light/realm.dart';
import 'package:flutterrealm_light/syncUser.dart';
import 'package:flutterrealm_light/results.dart';
import 'package:flutterrealm_light/types.dart';
import 'package:flutterrealm_light_example/photo_detail.dart';

import 'dart:collection';
import 'photo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _jwtString =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzb3J0ZWQtZmN0d2IiLCJleHAiOjI1MTYyMzkwMjIsInN1YiI6IjZkRWY2UzM3eGdRYlhXR09iMHVTNHBhMWhzQTIiLCJ1c2VyX2RhdGEiOnsibmFtZSI6IkFub255bW91cyJ9LCJpYXQiOjE1OTcwNjUzNjB9.aUjbxO_xLKrzTjypIvtZ_GIAH84QPESUKva9TB6pXO_nV1nrcDAXUbUaK-YBK_Qs2_Z-eiVbtiXBA69nsCxQVYpqMQLGM9XJl26MMhP1CYP99Ek7-Ni7kZBbcCc3Plj2NRRHY11vItclgG6nff3KBHMPxY66gxPKG7Uxw01K0lZ5VRjdM-a1U2Acxj7rBRyYXr8IPWrLldVtwWve3YfEc-a9CVKXfhX6-3Lo3AevTP1tCuiC7C7aYoUpDB8kyAxPDSPWfFaZID15Mv1AiL6PTi5-NO16KN0CaPiJf02q3TMJyNEdDoHMvVH5_LOGSHhwRP3jfbnt7EnYIvGW_daGJA';

  String _appId = 'sorted-fctwb';

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
      syncUser = await _login(_jwtString, _appId);
      print("${syncUser.identity}");
    } else {
      syncUser = fetchAllUsers[0].values.first;
    }

    _listenPhotoChange(syncUser);

    Photo photo = await _createPhoto(syncUser);
    print("Photo id: ${photo.id}");

    await _deletePhoto(syncUser, photo.id);

    // List<Photo> photos = await _getPhotos(syncUser);
    // print("Photos count: ${photos.length}");

    await syncUser.logout();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: '),
        ),
      ),
    );
  }

  Future<List<LinkedHashMap<String, SyncUser>>> fetchAll() async {
    List<LinkedHashMap<String, SyncUser>> users = await Realm.all(_appId);
    return users;
  }

  Future<SyncUser> _login(String jwt, String server) async {
    SyncCredentials syncCredentials =
        SyncCredentials(jwt, SyncCredentialsType.jwt);
    SyncUser user =
        await SyncUser.login(credentials: syncCredentials, appId: _appId);

    assert(user != null);
    return user;
  }

  Future<Photo> _createPhoto(SyncUser syncUser) async {
    Photo photo = Photo();
    photo.id = "12398234";

    PhotoDetail photoDetail = new PhotoDetail();
    photoDetail.centerx = 11;
    photoDetail.id = "111sss";
    photo.photoDetail = photoDetail;

    Realm realm = Realm(syncUser, _appId);

    Photo createdPhoto = await realm.create<Photo>(() {
      return new Photo();
    }, photo, policy: UpdatePolicy.modified);

    return createdPhoto;
  }

  Future<void> _deletePhoto(SyncUser syncUser, String primaryKey) async {
    Realm realm = Realm(syncUser, _appId);
    // Delete photo
    realm.delete<Photo>(primaryKey);
  }

  Future<List<Photo>> _getPhotos(SyncUser syncUser) async {
    Realm realm = Realm(syncUser, _appId);

    Results photoResult = realm.objects<Photo>(() {
      return new Photo();
    });
    List<Photo> photos = await photoResult.list();

    return photos;
  }

  Results _listener;
  StreamController<List<NotificationObject>> controller;
  _listenPhotoChange(SyncUser syncUser) async {
    Realm realm = Realm(syncUser, _appId);

    _listener = realm.objects<Photo>(() {
      return new Photo();
    });

    controller = await _listener.subscribe();
    controller.stream.listen((event) async {
      print(event);
      await _listener.unSubscribe();
    });
  }
}
