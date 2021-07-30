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
import Realm

class RealmQuery{
    init(realmApp: App, channel: FlutterMethodChannel?){
        self.realmApp = realmApp
        self.channel = channel
    }


    let realmApp: App

    private let channel: FlutterMethodChannel?
    private var notifications = [Int: Notifiable]()

    private let main = DispatchQueue.main
        
    func continueAction(action: Action, call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        switch action {
        case .objects:
            try objects(call, result: result)
        case .count:
            try count(call, result: result)
        case .create:
            try create(call, result: result)
        case .createList:
            try createList(call, result: result)
        case .login:
            try login(call, result: result)
        case .logout:
            try logout(call, result: result)
        case .logoutAll:
            try logoutAll(call, result: result)
        case .allUsers:
            try allUsers(call, result: result)
        case .asyncOpen:
            try asyncOpen(call, result: result)
        case .delete:
            try delete(call, result: result)
        case .subscribe:
            try subscribe(call, result: result)
        case .unSubscribe:
            try unSubscribe(call, result: result)
        case .deleteAll:
            try deleteAll(call, result: result)
        case .last:
            try last(call, result: result)
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

        let notification = NotificationProducer.newInstance(type: .result)
        notification.register(channel: channel, result: objects, id: listenId)
        notifications[listenId] = notification
        
        main.async {
            result( ["results": [String: Any]()] )
        }
    }
    
    private func watch(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }
        guard let listenId = dictionary["listenId"] as? Int else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        guard let database = dictionary["database"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        guard let collection = dictionary["collection"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }
        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }


        let notification = NotificationProducer.newInstance(type: .watch)
        notification.register(channel: channel, user: user, database: database, collection: collection, id: listenId)
        notifications[listenId] = notification
        
        main.async {
            result( ["results": [String: Any]()] )
        }
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
        
        main.async {
            result( ["results": [String: Any]()] )
        }
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
            
            main.async {
                result( ["results": dictionaries] )
            }
            return
        }

        objects.forEach { dictionaries.append($0.toDictionary()) }

        main.async {
            result( ["results": dictionaries] )
        }
    }

    private func count(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        let objects = try results(call, result: result)

        if let limit = dictionary["limit"] as? Int{
            main.async {
                result( ["count": limit] )
            }
            return
        }

        let count = objects.count
        
        main.async {
            result( ["count": count] )
        }
    }
    
    
    private func last(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        let objects = try results(call, result: result)

        var dictionaries = [[String: Any]]()
        
        if let limit = dictionary["limit"] as? Int, limit < objects.count{
            let dictionary = objects[limit].toDictionary()
            dictionaries.append(dictionary)
        }else{
            if let dictionary = objects.last?.toDictionary(){
                dictionaries.append(dictionary)
            }
        }

        main.async {
            result( ["results": dictionaries] )
        }
    }


    
    private func results(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws -> Results<DynamicObject>{
        // open realm in autoreleasepool to create tables and then dispose
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, partition: partition)
        var objects = realm.dynamicObjects(type)

        if let query = dictionary["query"] as? String{
            let predicate = NSPredicate(format: query)
            objects = objects.filter(predicate)
        }

        if let sorted = dictionary["sorted"] as? [Any]{
            var descriptors = [SortDescriptor]()
            for sort in sorted{
                if let s = sort as? [String: Any], let sortedTitle = s["sorted"] as? String, let ascending = s["ascending"] as? Bool{
                    descriptors.append(SortDescriptor(keyPath: sortedTitle, ascending: ascending))
                }
            }
            objects = objects.sorted(by: descriptors)
        }

        return objects
    }
    
    private func deleteAll(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, partition: partition)

        realm.beginWrite()
        realm.deleteAll()
        try realm.commitWrite()

        main.async {
            result([String: Any]())
        }
    }


    private func delete(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let primaryKey = dictionary["primaryKey"]
        guard primaryKey != nil else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, partition: partition)
        let object = realm.dynamicObject(ofType: type, forPrimaryKey: primaryKey!)

        guard let requiredObject = object else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.objectNotFoundForGivenIdentity)
        }

        realm.beginWrite()
        realm.delete(requiredObject)
        try realm.commitWrite()

        main.async {
            result([String: Any]())
        }
    }

    private func createList(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let policyInteger = dictionary["policy"] as? Int, let policy = Realm.UpdatePolicy.init(rawValue: policyInteger), let value = dictionary["value"] as? [Dictionary<String, Any>], let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, partition: partition)
        realm.beginWrite()
        value.forEach { value in
            realm.dynamicCreate(type, value: value, update: policy)
        }
        try realm.commitWrite()

        main.async {
            result([String: Any]())
        }
    }

    private func create(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let policyInteger = dictionary["policy"] as? Int, let policy = Realm.UpdatePolicy.init(rawValue: policyInteger), let value = dictionary["value"] as? Dictionary<String, Any>, let type = dictionary["type"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String  else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        let realm = try Realm.realm(user: user, partition: partition)

        realm.beginWrite()
        let updatedObject = realm.dynamicCreate(type, value: value, update: policy)
        try realm.commitWrite()

        let d = updatedObject.toDictionary()
        main.async {
            result(d)
        }
    }

    private func login(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let jwt = dictionary["jwt"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        
        let jwtCredentials = Credentials.jwt(token: jwt)

        realmApp.login(credentials: jwtCredentials) { result1 in
            switch result1 {
            case .success(let syncUser):
                let identity = syncUser.identities.first?.identifier ?? ""
                result(["identity": identity, "id": syncUser.id])
            case .failure(let error):
                result(["error": error.localizedDescription])
            }
        }

    }


    private func asyncOpen(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let partition = dictionary["partition"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }
        
        
        Realm.asyncOpen(configuration: Realm.configuration(user: user, partition: partition), callbackQueue: DispatchQueue.main) { result1 in
            switch result1 {
            case .success( _):
                result(["identity": identity])
            case .failure(let error):
                result(["error": error.localizedDescription])
            }
        }
    }


    private func logoutAll(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        realmApp.allUsers.forEach { (key: String, value: RLMUser) in
            value.logOut{_ in

            }
        }

        main.async {
            result([String: Any]())
        }
    }


    private func logout(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        guard let dictionary = call.arguments as? NSDictionary else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.noArgumentsWasPassesError)
        }

        guard let identity = dictionary["identity"] as? String else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.oneOffArgumentsNotPassesError)
        }

        guard let id = realmApp.user(id: identity)?.id else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        guard let user = Realm.user(app: realmApp, id: id) else{
            throw FluterRealmError.runtimeError(SwiftFlutterrealm_lightPlugin.notFoundForGivenIdentityError)
        }

        user.logOut { (error) in

        }

        main.async {
            result([String: Any]())
        }
    }

    private func allUsers(_ call: FlutterMethodCall, result: @escaping FlutterResult) throws{
        let dictionaries = realmApp.allUsers.filter{ $0.value.state == .loggedIn }.map { (key: String, syncUser: User) -> [String: [String: Any]] in

            let ident = syncUser.metaId ?? ""
            return [ident: ["identity": ident, "id": syncUser.id ]]
        }

        main.async {
            result(["results": dictionaries])
        }
    }

}

private extension User{
    var metaId: String? { identities.first?.identifier }
}

private extension App{
    func user(id: String) -> User?{
        return allUsers.first {
            let (_, value) = $0
            return value.metaId == id
            }?.value
    }
}

private enum ConnectionState{
    case none, connecting
}
