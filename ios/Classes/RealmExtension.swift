//
//  RealmExtension.swift
//  flutterrealm_light
//
//  Created by Grigori on 2/24/20.
//

import Foundation
import RealmSwift
import Realm.Dynamic

extension Realm {
    static func realm(user: User, configuration: Realm.Configuration) throws -> Realm{
        do {
            let realm = try Realm(configuration: configuration)
            return realm
        } catch {
            throw FluterRealmError.runtimeError("Was not able create realm \(error)")
        }
    }

    static func user(app: App, id: String) -> User?{
        return app.allUsers.filter{ $0.value.state == .loggedIn }.first { (key: String, user: User) -> Bool in
            return user.id == id
            }?.value
    }
}


extension Results {
    func limited(_ limit: Int?) -> Slice<Results> {

        guard let limit = limit else {
            return self[0..<count]
        }

        if count > limit {
            return self[0..<limit]
        } else {
            return self[0..<count]
        }
    }
}


extension Object {
    func toDictionary() -> [String: Any] {
        if isInvalidated{
            return [String: Any]()
        }

        let properties = self.objectSchema.properties.map { $0.name }
        var mutabledic = self.dictionaryWithValues(forKeys: properties)

        for prop in self.objectSchema.properties as [Property] {
            let value = self[prop.name]
            // find lists
            if let relationShip = value as? Object {
                mutabledic[prop.name] = relationShip.toDictionary()
            } else if prop.isSet || prop.isArray {
                var dictionaries = [[String: Any]]()
                
                let list = self.dynamicList(prop.name)
                
                for val in list{
                    dictionaries.append(val.toDictionary())
                }
                mutabledic[prop.name] = dictionaries

            } else {
                mutabledic[prop.name] = self[prop.name]
            }
        }
        return mutabledic
    }
}

