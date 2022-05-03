// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter_driver/driver_extension.dart';
import 'package:test/test.dart';

import 'package:flutter_driver/flutter_driver.dart';

void main() {
  enableFlutterDriverExtension();

  group('Realm plugin test', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() {});

    test('Fetch all users', () {});

    test('Login with jwt', () {
      String jwt = "";
      String server = "";
    });

    test('Create photo', () {
      String jwt = "";
      String server = "";
    });
  });
}
