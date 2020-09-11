enum Action {
  objects,
  create,
  delete,
  beginWrite,
  commitWrite,
  login,
  logout,
  logoutAll,
  allUsers,
  subscribe,
  unSubscribe,
  asyncOpen
}

enum UpdatePolicy {
  ///Throw an exception. This is the default when no policy is specified for `add()` or `create()`.
  ///
  ///This behavior is the same as passing `update: false` to `add()` or `create()`.
  error,

  /// Overwrite only properties in the existing object which are different from the new values. This results
  /// in change notifications reporting only the properties which changed, and influences the sync merge logic.
  ///
  /// If few or no of the properties are changing this will be faster than .all and reduce how much data has
  /// to be written to the Realm file. If all of the properties are changing, it may be slower than .all (but
  /// will never result in *more* data being written).
  modified,

  /// Overwrite all properties in the existing object with the new values, even if they have not changed. This
  /// results in change notifications reporting all properties as changed, and influences the sync merge logic.
  all
}

extension UpdatePolicyExtension on UpdatePolicy {
  int get value {
    switch (this) {
      case UpdatePolicy.error:
        return 1;
      case UpdatePolicy.modified:
        return 3;
      case UpdatePolicy.all:
        return 2;
    }

    return 1;
  }
}

extension ActionExtension on Action {
  String get name {
    switch (this) {
      case Action.objects:
        return 'objects';
      case Action.create:
        return 'create';
      case Action.beginWrite:
        return 'beginWrite';
      case Action.commitWrite:
        return "commitWrite";
      case Action.login:
        return "login";
      case Action.logout:
        return "logout";
      case Action.logoutAll:
        return "logoutAll";
      case Action.allUsers:
        return 'allUsers';
      case Action.delete:
        return 'delete';
      case Action.subscribe:
        return 'subscribe';
      case Action.unSubscribe:
        return 'unSubscribe';
      case Action.asyncOpen:
        return 'asyncOpen';
        break;
    }

    return "";
  }
}
