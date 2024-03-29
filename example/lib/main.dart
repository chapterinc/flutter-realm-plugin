import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterrealm_light/realm.dart';
import 'package:flutterrealm_light/syncUser.dart';
import 'package:flutterrealm_light/results.dart';
import 'package:flutterrealm_light/types.dart';
import 'package:flutterrealm_light_example/photo_detail.dart';

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
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJzb3J0ZWQtZmx1dHRlci1tdGZwcyIsImV4cCI6MjUxNjIzOTAyMiwic3ViIjoiMzMzMzMzMTMiLCJ1c2VyX2RhdGEiOnsibmFtZSI6IkFub255bW91cyJ9LCJpYXQiOjE1OTk0NzU3MDB9.NY7jtenBtOH64g6nwSGoMsw0l43HsQgxNOcK8ljr2ZgNAJKwxFOnceddNAV-SGz9zMVodYOGQtDB4o-KpkG5XKb5jRx-5_Q-NzlgfKab-H5buVZ5YmVIPR0yl7S2nqiy2eC1cy_E_5HM9SjskOe-XeHyfN4dXUdEa98PTBxkJKqyJtUCFM1EwgAVvS1XW3nsQOS-89_Kd__G3YmDPdtRIwmXUqHKRzaUBBstlZjFChNGX0OQsYDetACG-iB-ZE3ywbpQnd4Y5qchFcU2EVLaP3rk7RUzSzH0KhG8PP0BSKyTjYVAIH3hA60z1lBYwZTyRJdXVntdGuVzlAp1FwzSGQ';

  String _appId = 'sorted-flutter-mtfps';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    await testWithJwt(_jwtString, "1111");
    await testWithJwt(_jwtString1, "33333313");
  }

  Future<void> testWithJwt(String jwt, String userId) async {
    // Check all users
    List<Map<String, SyncUser>> fetchAllUsers = await fetchAll();
    print("${fetchAllUsers.length}");
    SyncUser? syncUser = await _login(jwt, _appId);
    Map<String, SyncUser> map =
        fetchAllUsers.firstWhere((element) => element[userId] != null);

    List<Photo> photos = await _getPhotos(syncUser);

    syncUser.partition = syncUser.identity;

    await syncUser.asyncOpen();
    print("${syncUser.identity}");

    _listenPhotoChange(syncUser);

    Photo photo = await _createPhoto(syncUser);
    print("Photo id: ${photo.id}");

    print("Photos count: ${photos.length}");

    await _deletePhoto(syncUser, photo.id);

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

  Future<List<Map<String, SyncUser>>> fetchAll() async {
    List<Map<String, SyncUser>> users = await Realm.all(_appId);
    return users;
  }

  Future<SyncUser> _login(String jwt, String _appId) async {
    SyncCredentials syncCredentials = SyncCredentials(jwt);
    SyncUser user =
        await SyncUser.login(credentials: syncCredentials, appId: _appId);

    return user;
  }

  Future<Photo> _createPhoto(SyncUser syncUser) async {
    Photo photo = Photo();
    photo.id = "12398234";

    PhotoDetail photoDetail = new PhotoDetail();
    photoDetail.centerx = 11;
    photoDetail.id = "111sss";
    photo.photoDetail = photoDetail;

    Realm realm = Realm(syncUser, _appId, syncUser.identity);

    Photo createdPhoto = await realm.create<Photo>(() {
      return new Photo();
    }, photo, policy: UpdatePolicy.modified);

    return createdPhoto;
  }

  Future<void> _deletePhoto(SyncUser syncUser, String primaryKey) async {
    Realm realm = Realm(syncUser, _appId, syncUser.identity);
    // Delete photo
    realm.delete<Photo>(primaryKey);
  }

  Future<List<Photo>> _getPhotos(SyncUser syncUser) async {
    Realm realm = Realm(syncUser, _appId, syncUser.identity);

    Results photoResult = realm.objects<Photo>(() {
      return new Photo();
    });
    photoResult.sorted = [Sort(sorted: "id", ascending: true)];
    List<Photo> photos = await photoResult.list();

    return photos;
  }

  Results? _listener;
  StreamController<List<NotificationObject>>? controller;
  _listenPhotoChange(SyncUser syncUser) async {
    Realm realm = Realm(syncUser, _appId, syncUser.identity);

    _listener = realm.objects<Photo>(() {
      return new Photo();
    });

    final listener = _listener;
    if (listener == null) {
      return;
    }

    // controller = (await listener.subscribe())!;
    // controller?.stream.listen((event) async {
    //   print(event);
    //   await _listener?.unSubscribe();
    // });
  }
}
