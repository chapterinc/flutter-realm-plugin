//
//  NotificationManager.swift
//  flutterrealm_light
//
//  Created by Grigori on 4/29/20.
//

import Foundation
import RealmSwift

enum NotifieTypeEnum: String {
    case result, watch
}

protocol Notifiable {
    func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int)
    func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int);
    func unRegister();
}

class NotificationProducer {
    static func newInstance(type: NotifieTypeEnum) -> Notifiable{
        switch type {
        case .result:
            return Notification()
        case .watch:
            return WatchNotification()
        }
    }
}

fileprivate class Notification: Notifiable{
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
    
    func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int){
        assert(true, "This method not implemented")
    }
    
    func unRegister(){
        notificationToken?.invalidate()
    }
    
    deinit {
        notificationToken?.invalidate()
    }

}


fileprivate class WatchNotification: Notifiable{
    private var mongoCollection: MongoCollection?
    private var stream: ChangeStream?
    private var delegate: ChangeDelegate?
    
    func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int){
        assert(true, "This method not implemented")
    }

    func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int){
        let deleg = ChangeDelegate(channel: channel)
        
        mongoCollection = user.mongoClient("mongodb-atlas").database(named: database).collection(withName: collection)
        stream = mongoCollection?.watch(matchFilter:[:], delegate: deleg)
        
        // Initialize global parameter
        delegate = deleg
    }

    func unRegister(){
        stream?.close()
    }
}


fileprivate class ChangeDelegate: ChangeEventDelegate {
    init(channel: FlutterMethodChannel?){
        self.channel = channel
    }
    
    var channel: FlutterMethodChannel?
    func changeStreamDidOpen(_ changeStream: ChangeStream) {
        
    }
    
    func changeStreamDidClose(with error: Error?) {
        
    }
    
    func changeStreamDidReceive(error: Error) {
        
    }
    
    func changeStreamDidReceive(changeEvent: AnyBSON?) {
        print(changeEvent)
    }
    
}


