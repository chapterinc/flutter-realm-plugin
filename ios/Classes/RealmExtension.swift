//
//  RealmExtension.swift
//  flutterrealm_light
//
//  Created by Grigori on 2/24/20.
//

import Foundation
import RealmSwift
import Realm.Dynamic

extension Realm{
    static func configuration(user: User, partition: String) -> Realm.Configuration {
        let configuration = user.configuration(partitionValue: partition)
        return configuration
    }

    static func realm(user: User, partition: String) throws -> Realm{
        do {
            let conf = configuration(user: user, partition: partition)
            let realm = try Realm(configuration: conf)
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
            // find lists
            if let relationShip = self[prop.name] as? Object {
                mutabledic[prop.name] = relationShip.toDictionary()
            } else if let list = self[prop.name] as? ListBase {
                var dictionaries = [[String: Any]]()
                for i in 0..<list.count{
                    dictionaries.append((list._rlmArray.object(at: UInt(i)) as! Object).toDictionary())
                }
                mutabledic[prop.name] = dictionaries

            } else {
                mutabledic[prop.name] = self[prop.name]
            }
        }
        return mutabledic
    }
}

