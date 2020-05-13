//
//  NotificationManager.swift
//  flutterrealm_light
//
//  Created by Grigori on 4/29/20.
//

import Foundation
import RealmSwift

class Notification{
    var notificationToken: NotificationToken?
    func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int) {
        notificationToken = result.observe({ (change) in
            switch change {
            case .initial(_):
                break
            case .update(_, let deletions, let insertions, let modifications):
                var dictionaries = [String: Any]()
                
                let deletetDictionary = deletions.map { (value) -> [Int: Any?] in
                    return [value: nil]
                }
                dictionaries["deletions"] = deletetDictionary
                
                let insertionDictionary = insertions.map { (value) -> [Int: Any?] in
                    return [value: result[value].toDictionary()]
                }
                dictionaries["insertions"] = insertionDictionary

                let modificationDictionary = modifications.map { (value) -> [Int: Any?] in
                    return [value: result[value].toDictionary()]
                }
                dictionaries["modifications"] = modificationDictionary
                dictionaries["id"] = id

                channel?.invokeMethod("change", arguments: dictionaries)
            case .error(_):
                break
            }
        })
    }
    
    func unRegister(){
        notificationToken?.invalidate()
    }
    
    deinit {
        notificationToken?.invalidate()
    }

}
