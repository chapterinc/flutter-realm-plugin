import Flutter
import UIKit
import RealmSwift
import Realm.Dynamic
import Realm.Private

enum Action: String {
    case objects
    case create
    case delete
    case login
    case logout
    case allUsers
}

public class SwiftFlutterrealm_lightPlugin: NSObject, FlutterPlugin {
    static let noArgumentsWasPassesError = "no arguments was passed"
    static let oneOffArgumentsNotPassesError = "one of arguments not passed correctly"
    static let databaseUrlWasNotSet = "database url was not set"
    static let notFoundForGivenIdentityError = "user not found for given identity"
    static let objectNotFoundForGivenIdentity = "object not found for given identity"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutterrealm_light", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterrealm_lightPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let action = Action(rawValue: call.method) else{
            result(["error": "Problem on parse action"])
            return
        }

        do {
            try continueAction(action: action, call: call, result: result)
        }catch {
            result(["error": "\(error)"])
        }

    }

    private func continueAction(action: Action, call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        switch action {
          case .objects:
              try objects(call, result: result)
          case .create:
              try beginWrite(call)
              try create(call, result: result)
              try commitWrite(call)
          case .login:
              try login(call, result: result)
          case .logout:
              try logout(call, result: result)
          case .allUsers:
              try allUsers(call, result: result)
        case .delete:
            try beginWrite(call)
            try delete(call, result: result)
            try commitWrite(call)
          }
    }

    private func objects(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        var objects = realm.dynamicObjects(type)

        if let query = dictionary["query"] as? String{
            let predicate = NSPredicate(format: query)
            objects = objects.filter(predicate)
        }

        if let sorted = dictionary["sorted"] as? String, let ascending = dictionary["ascending"] as? Bool{
            objects = objects.sorted(byKeyPath: sorted, ascending: ascending)
        }

        var dictionaries = [[String: Any]]()
        if let limit = dictionary["limit"] as? Int{
            objects.limited(limit).forEach { dictionaries.append($0.toDictionary())  }
            result( ["results": dictionaries] )
            return
        }

        objects.forEach { dictionaries.append($0.toDictionary()) }

        result( ["results": dictionaries] )
    }

    private func delete(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        
        guard let primaryKey = dictionary["primaryKey"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        let object = realm.dynamicObject(ofType: type, forPrimaryKey: primaryKey)
        
        guard let requiredObject = object else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.objectNotFoundForGivenIdentity)
        }
        realm.delete(requiredObject)
        result([String: Any]())
    }

    private func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let policyInteger = dictionary["policy"] as? Int, let policy = Realm.UpdatePolicy.init(rawValue: policyInteger), let value = dictionary["value"] as? Dictionary<String, Any>, let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        let updatedObject = realm.dynamicCreate(type, value: value, update: policy)

        result(updatedObject.toDictionary())
    }

    private func beginWrite(_ call: FlutterMethodCall) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.databaseUrlWasNotSet)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        realm.beginWrite()
    }

    private func commitWrite(_ call: FlutterMethodCall) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        try realm.commitWrite()
    }

    private func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let jwt = dictionary["jwt"] as? String, let server = dictionary["server"] as? String, let serverUrl = URL(string: server) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let jwtCredentials = SyncCredentials.jwt(jwt)
        SyncUser.logIn(with: jwtCredentials, server: serverUrl) { (syncUser, e) in
            result(["identity": syncUser?.identity])
        }
    }

    private func logout(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        user.logOut()

        result([String: Any]())
    }

    private func allUsers(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        let dictionaries = SyncUser.all.map { (key: String, syncUser: SyncUser) -> [String: [String: Any]] in
            return [key: ["identity": syncUser.identity ?? ""]]
        }

        result(["results": dictionaries])
    }
}
