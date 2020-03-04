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
