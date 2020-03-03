import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterrealm/realm.dart';
import 'package:flutterrealm/syncUser.dart';
import 'package:flutterrealm/results.dart';
import 'package:flutterrealm/types.dart';
import 'package:flutterrealm_example/photo_detail.dart';

import 'dart:collection';
import 'photo.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _jwtString = '';
  String _authenticationPath = '';
  String _databasePath = '';

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

    PhotoDetail photoDetail = new PhotoDetail();
    photoDetail.centerx = 11;
    photoDetail.id = "111sss";
    photo.photoDetail = photoDetail;

    Realm realm = Realm(syncUser, _databasePath);

    Photo createdPhoto = await realm.create<Photo>(() {
      return new Photo();
    }, photo, policy: UpdatePolicy.modified);

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
