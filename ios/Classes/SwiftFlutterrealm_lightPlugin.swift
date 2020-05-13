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
    case subscribe
    case unSubscribe
}

public class SwiftFlutterrealm_lightPlugin: NSObject, FlutterPlugin {
    static let noArgumentsWasPassesError = "no arguments was passed"
    static let oneOffArgumentsNotPassesError = "one of arguments not passed correctly"
    static let databaseUrlWasNotSet = "database url was not set"
    static let notFoundForGivenIdentityError = "user not found for given identity"
    static let objectNotFoundForGivenIdentity = "object not found for given identity"

    var notifications = [Int: Notification]()
    
    var channel: FlutterMethodChannel?
    public init(channel: FlutterMethodChannel? = nil) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutterrealm_light", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterrealm_lightPlugin(channel: channel)
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
              try create(call, result: result)
          case .login:
              try login(call, result: result)
          case .logout:
              try logout(call, result: result)
          case .allUsers:
              try allUsers(call, result: result)
          case .delete:
              try delete(call, result: result)
          case .subscribe:
              try subscribe(call, result: result)
          case .unSubscribe:
              try unSubscribe(call, result: result)
          }
    }

    private func subscribe(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }
        
        
        let objects = try results(call, result: result)
        guard let listenId = dictionary["listenId"] as? Int else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let notification = Notification()
        notification.register(channel: channel, result: objects, id: listenId)
        notifications[listenId] = notification
        result( ["results": [String: Any]()] )
    }
    
    private func unSubscribe(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }
        
        
        guard let listenId = dictionary["listenId"] as? Int else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let notification = notifications[listenId]
        notification?.unRegister()
        notifications[listenId] = nil
        result( ["results": [String: Any]()] )
    }


    private func objects(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        let objects = try results(call, result: result)
        
        var dictionaries = [[String: Any]]()
        if let limit = dictionary["limit"] as? Int{
            objects.limited(limit).forEach { dictionaries.append($0.toDictionary())  }
            result( ["results": dictionaries] )
            return
        }

        objects.forEach { dictionaries.append($0.toDictionary()) }

        result( ["results": dictionaries] )
    }
    
    private func results(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws -> Results<DynamicObject>{
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
        
        return objects
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

        let primaryKey = dictionary["primaryKey"]
        guard primaryKey != nil else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, databaseUrl: databaseUrl)
        let object = realm.dynamicObject(ofType: type, forPrimaryKey: primaryKey!)

        guard let requiredObject = object else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.objectNotFoundForGivenIdentity)
        }

        realm.beginWrite()
        realm.delete(requiredObject)
        try realm.commitWrite()

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

        realm.beginWrite()
        let updatedObject = realm.dynamicCreate(type, value: value, update: policy)
        try realm.commitWrite()

        result(updatedObject.toDictionary())
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
