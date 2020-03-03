# [fluttertoast](https://pub.dartlang.org/packages/fluttertoast)

Android and iOS Toast Library for Flutter

> Supported Platforms
>
> - IOS

## How to Use

```yaml
# add this line to your dependencies
fluterrealm: ^0.1.0
```

```dart
import 'package:fluterrealm/fluterrealm.dart';
```

```dart
    SyncCredentials syncCredentials =
        SyncCredentials(jwt, SyncCredentialsType.jwt);
    SyncUser user =
        await SyncUser.login(credentials: syncCredentials, server: server);
```

| property        | description                                                        |
| --------------- | ------------------------------------------------------------------ |
| msg             | String (Not Null)(required)                                        |
| toastLength     | Toast.LENGTH_SHORT or Toast.LENGTH_LONG (optional)                 |
| gravity         | ToastGravity.TOP (or) ToastGravity.CENTER (or) ToastGravity.BOTTOM |
| timeInSecForIos | int (only for ios)                                                 |
| bgcolor         | Colors.red                                                         |
| textcolor       | Colors.white                                                       |
| fontSize        | 16.0 (float)                                                       |

### To logout

```dart
syncUser.logout()
```

## If you need any features suggest