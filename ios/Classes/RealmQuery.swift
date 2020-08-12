//
//  RealmQuery.swift
//  flutterrealm_light
//
//  Created by Grigori on 8/10/20.
//

import Foundation
import RealmSwift
import Realm.Dynamic
import Realm.Private

class RealmQuery{
    var notifications = [Int: Notification]()

    var realmApp: RealmApp
    
    var channel: FlutterMethodChannel?

    init(realmApp: RealmApp, channel: FlutterMethodChannel?){
        self.realmApp = realmApp
        self.channel = channel
    }
    
    func continueAction(action: Action, call: FlutterMethodCall, result: @escaping FlutterResult) throws{
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

        guard let user = Realm.user(app: realmApp, identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user)
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

        guard let user = Realm.user(app: realmApp, identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let primaryKey = dictionary["primaryKey"]
        guard primaryKey != nil else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user)
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

        guard let user = Realm.user(app: realmApp, identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let policyInteger = dictionary["policy"] as? Int, let policy = Realm.UpdatePolicy.init(rawValue: policyInteger), let value = dictionary["value"] as? Dictionary<String, Any>, let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user)

        realm.beginWrite()
        let updatedObject = realm.dynamicCreate(type, value: value, update: policy)
        try realm.commitWrite()

        result(updatedObject.toDictionary())
    }

    private func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let jwt = dictionary["jwt"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let jwtCredentials = AppCredentials.init(jwt: jwt)

        realmApp.login(withCredential: jwtCredentials) { (syncUser, e) in
            let identity = syncUser?.identities().first?.identity ?? ""
            let id = syncUser?.identity ?? ""

            self.setIdentity(id: id, identity: identity)

            result(["identity": identity])
        }
    }

    private func logout(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let user = Realm.user(app: realmApp, identifier: identity) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        
        realmApp.logOut(user) { (error) in
            
        }

        result([String: Any]())
    }

    private func allUsers(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        let dictionaries = realmApp.allUsers().map { (key: String, syncUser: SyncUser) -> [String: [String: Any]] in
            
            let ident = identity(id: syncUser.identity ?? "")
            return [ident: ["identity": ident]]
        }

        result(["results": dictionaries])
    }

}

/// Realm sdk don't save identities for fix that bug we save it manually
private extension RealmQuery{
    func setIdentity(id: String, identity: String){
        UserDefaults.standard.set(identity, forKey: id)
        UserDefaults.standard.synchronize()
    }
    
    func identity(id: String) -> String{
        return UserDefaults.standard.string(forKey: id) ?? ""
    }
}
