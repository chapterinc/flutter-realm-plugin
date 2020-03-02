// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_driver/flutter_driver.dart';

import 'package:flutterrealm/realm.dart';
import 'package:flutterrealm/object.dart';
import 'package:flutterrealm/syncUser.dart';

import 'dart:collection';

class Photo extends RLMObject {
  String id;

  @override
  Map toJson() {
    Map map = super.toJson();
    map["id"] = id;

    return map;
  }
}

void main() {
  group('Realm plugin', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    testWidgets('Fetch all users', (WidgetTester tester) async {
      List<LinkedHashMap<String, SyncUser>> users = await Realm.all();
    });

    testWidgets('Login with jwt', (WidgetTester tester) async {
      String jwt = "";
      String server = "";
      SyncCredentials syncCredentials =
          SyncCredentials(jwt, SyncCredentialsType.jwt);
      SyncUser user =
          await SyncUser.login(credentials: syncCredentials, server: server);

      assert(user != null);
      return user;
    });

    testWidgets('Create photo', (WidgetTester tester) async {
      String jwt = "";
      String server = "";

      SyncCredentials syncCredentials =
          SyncCredentials(jwt, SyncCredentialsType.jwt);
      SyncUser user =
          await SyncUser.login(credentials: syncCredentials, server: server);

      Photo photo = Photo();
      photo.id = "123";

      Realm realm = Realm(user, "");

      Photo createdPhoto = await realm.create<Photo>(() {
        return Photo();
      }, photo);

      assert(createdPhoto.id != photo.id);

      return createdPhoto;
    });
  });
}
