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
  // User with id 111
  String _jwtString =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzb3J0ZWQtZmx1dHRlci1tdGZwcyIsImV4cCI6MjUxNjIzOTAyMiwic3ViIjoiMTExMSIsInVzZXJfZGF0YSI6eyJuYW1lIjoiSmVhbiBWYWxqZWFuIiwiYWxpYXNlcyI6WyJNb25zaWV1ciBNYWRlbGVpbmUiLCJVbHRpbWUgRmF1Y2hlbGV2ZW50IiwiVXJiYWluIEZhYnJlIl19LCJpYXQiOjE1OTcxNDczMDB9.EztS069aiSCdGgiAMH8u2dOAtV_p2Z2kQey-2_Q6dhQEYY5dQeWtPWU1IIrbH8oM84Sa_zj5oW9v8AtOssopmF4SD__-tCB45otQqh2UljmQWHyBK4PdIoC7gjMs6Dhhw5aJlCF-hKRzYQruqsBnIq85sHR9o2QtC66-L4uu4PItDQQvr4gItQrYHsfplCnZrSC-PMlp8MleFq83lov-F4mblAJaluTxMQW8tYxv3XIGiIsoSRrP00dmxwYyl61s5-AOFBPQm29EmTb185M5IxU3pLBkuU_T7RvIGsod-x75b7PkD-cirOVYMpdYpHq3NCugAwTVZ81m_CtISNTibw';

// User with id -10
  String _jwtString1 =
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzb3J0ZWQtZmx1dHRlci1tdGZwcyIsImV4cCI6MjUxNjIzOTAyMiwic3ViIjotMTAsInVzZXJfZGF0YSI6eyJuYW1lIjoiQW5vbnltb3VzIn0sImlhdCI6MTU5OTMyMTgxMX0.Gnrj6Tv6WDUFpVvh8hofMMFUTvQEvBtefjewMxr6fbhlF3QnbE3tnGHHh8zNNVwrLl7nWMHgosdIptBOwVYI7h3VtMT6ZaHnvEY5ub_jM7oT2dSbf3t__hqMul4Vy-w9jKUBuLEB1pBdkXEUbntlpoHj9Cy9cXZcfjPOXPpU_nDUQhAin9k0XF-y0p-xzNPp0UDmueaO21B8B5FXojUrjkKxcwcciXeMqCFcQQWgALgqDkMcSO0NamIhCvAZyP5hNRPuvThdsScUkrgqiKFd2d704cIpPZkC6T7gFhLFNE0QefXvMgVy9rK7Ge0PH0UTzQ-cUxxLRU0PBvIw96sUJw';

  String _appId = 'sorted-flutter-mtfps';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await testWithJwt(_jwtString);
    await testWithJwt(_jwtString1);
  }

  Future<void> testWithJwt(String jwt) async {
    // Check all users
    List<LinkedHashMap<String, SyncUser>> fetchAllUsers = await fetchAll();
    print("${fetchAllUsers.length}");
    SyncUser syncUser;

    // fetchAllUsers.firstWhere((element) => element[])
    // if (fetchAllUsers.length == 0) {
    syncUser = await _login(jwt, _appId);
    //   print("${syncUser.identity}");
    // } else {
    //   syncUser = fetchAllUsers[0].values.first;
    // }

    _listenPhotoChange(syncUser);

    Photo photo = await _createPhoto(syncUser);
    print("Photo id: ${photo.id}");

    List<Photo> photos = await _getPhotos(syncUser);
    print("Photos count: ${photos.length}");

    await _deletePhoto(syncUser, photo.id);

    // await syncUser.logout();
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

  Future<SyncUser> _login(String jwt, String _appId) async {
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
