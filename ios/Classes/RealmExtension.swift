//
//  RealmExtension.swift
//  flutterrealm
//
//  Created by Grigori on 2/24/20.
//

import Foundation
import RealmSwift
import Realm.Dynamic

extension Realm{
    static private func configuration(user: SyncUser, server: String) -> Realm.Configuration {
        let configuration = user.configuration(realmURL: URL(string: server), fullSynchronization: true)
        return configuration
    }

    static func realm(user: SyncUser, databaseUrl: String) throws -> Realm{
        do {
            let conf = configuration(user: user, server: databaseUrl)
            let realm = try Realm(configuration: conf)
            return realm
        } catch {
            throw FluterRealmError.runtimeError("Was not able create realm \(error)")
        }
    }
    
    static func user(identifier: String) -> SyncUser?{
        return SyncUser.all.first { (key: String, value: SyncUser) -> Bool in
            return key.contains(identifier)
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
            } else if let _ = self[prop.name] as? ListBase {
            } else {
                mutabledic[prop.name] = self[prop.name]
            }
        }
        return mutabledic
    }
}
