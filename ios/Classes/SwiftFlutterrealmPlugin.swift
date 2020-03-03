import Flutter
import UIKit
import RealmSwift
import Realm.Dynamic
import Realm.Private

enum Action: String {
    case objects
    case create
    case login
    case logout
    case allUsers
}

public class SwiftFlutterrealmPlugin: NSObject, FlutterPlugin {
    static let noArgumentsWasPassesError = "no arguments was passed"
    static let oneOffArgumentsNotPassesError = "one of arguments not passed correctly"
    static let databaseUrlWasNotSet = "database url was not set"
    static let notFoundForGivenIdentityError = "user not found for given identity"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutterrealm", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterrealmPlugin()
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
          }
    }

    private func objects(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        var objects = realm.dynamicObjects(type)

        if let query = dictionary["query"] as? String{
            let predicate = NSPredicate(format: query)
            objects = objects.filter(predicate)
        }

        if let limit = dictionary["limit"] as? Int{
            let limitedObjects =  objects.limited(limit).map { $0.toDictionary() }
            result(limitedObjects)
            return
        }

        var dictionaries = [[String: Any]]()
        objects.forEach { dictionaries.append($0.toDictionary()) }

        result( ["results": dictionaries] )
    }

    private func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let policyInteger = dictionary["policy"] as? Int, let policy = Realm.UpdatePolicy.init(rawValue: policyInteger), let value = dictionary["value"] as? Dictionary<String, Any>, let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        let updatedObject = realm.dynamicCreate(type, value: value, update: policy)

        result(updatedObject.toDictionary())
    }

    private func beginWrite(_ call: FlutterMethodCall) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.databaseUrlWasNotSet)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }
        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        realm.beginWrite()
    }

    private func commitWrite(_ call: FlutterMethodCall) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let databaseUrl = dictionary["databaseUrl"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.databaseUrlWasNotSet)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }
        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        try realm.commitWrite()
    }

    private func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let jwt = dictionary["jwt"] as? String, let server = dictionary["server"] as? String, let serverUrl = URL(string: server) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        let jwtCredentials = SyncCredentials.jwt(jwt)
        SyncUser.logIn(with: jwtCredentials, server: serverUrl) { (syncUser, e) in
            result(["identity": syncUser?.identity])
        }
    }

    private func logout(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
        }

        guard let user = Realm.user(identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealmPlugin.oneOffArgumentsNotPassesError)
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
