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
    static private func configuration(user: SyncUser) -> Realm.Configuration {
        let configuration = user.configuration(partitionValue: 0)
        return configuration
    }

    static func realm(user: SyncUser) throws -> Realm{
        do {
            let conf = configuration(user: user)
            let realm = try Realm(configuration: conf)
            return realm
        } catch {
            throw FluterRealmError.runtimeError("Was not able create realm \(error)")
        }
    }

    static func user(app: RealmApp, identifier: String) -> SyncUser?{
        return app.allUsers().first { (key: String, user: SyncUser) -> Bool in
            return user.identities().first?.identity == identifier
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

