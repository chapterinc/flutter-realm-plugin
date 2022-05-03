# [flutterrealm_light](https://pub.dartlang.org/packages/flutterrealm_light)

Android and iOS Library for Realm

> Supported Platforms
>
> - IOS

## How to Use

```yaml
# add this line to your dependencies
fluterrealm: ^1.0.19+1
```

```dart
import 'package:flutterrealm_light/realm.dart';
```

```dart
    SyncCredentials syncCredentials =
        SyncCredentials(jwt, SyncCredentialsType.jwt);
    SyncUser user =
        await SyncUser.login(credentials: syncCredentials, server: server);
```

### To logout

```dart
syncUser.logout()
```