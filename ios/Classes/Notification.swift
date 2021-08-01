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
    func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int, filter: [String: Any]);
    func unRegister();
}

class NotifieParent: Notifiable {
    func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int) {
        assert(true, "This method not implemented")
    }
    
    func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int, filter: [String: Any] = [:]) {
        assert(true, "This method not implemented")
    }
    
    func unRegister() {
        assert(true, "This method not implemented")
    }
    
    fileprivate static let insertKey = "insertions"
    fileprivate static let deleteKey = "deletions"
    fileprivate static let modifieKey = "modifications"
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

fileprivate class Notification: NotifieParent{
    var notificationToken: NotificationToken?
    
    override func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int) {
        notificationToken = result.observe({ (change) in
            switch change {
            case .initial(_):
                break
            case .update(_, let deletions, let insertions, let modifications):
                var dictionaries = [String: Any]()
                
                let deletetDictionary = deletions.map { (value) -> [Int: Any?] in
                    return [value: nil]
                }
                dictionaries[Notification.deleteKey] = deletetDictionary
                
                let insertionDictionary = insertions.map { (value) -> [Int: Any?] in
                    return [value: result[value].toDictionary()]
                }
                dictionaries[Notification.insertKey] = insertionDictionary

                let modificationDictionary = modifications.map { (value) -> [Int: Any?] in
                    return [value: result[value].toDictionary()]
                }
                dictionaries[Notification.modifieKey] = modificationDictionary
                dictionaries["id"] = id

                channel?.invokeMethod("change", arguments: dictionaries)
            case .error(_):
                break
            }
        })
    }
    
    override func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int, filter: [String: Any] = [:]){
        assert(true, "This method not implemented")
    }
    
    override func unRegister(){
        notificationToken?.invalidate()
    }
    
    deinit {
        notificationToken?.invalidate()
    }

}


fileprivate class WatchNotification: NotifieParent{
    private var mongoCollection: MongoCollection?
    private var stream: ChangeStream?
    private var delegate: ChangeDelegate?
    
    override func register(channel: FlutterMethodChannel?, result: Results<DynamicObject>, id: Int){
        assert(true, "This method not implemented")
    }

    override func register(channel: FlutterMethodChannel?, user: User, database: String, collection: String, id: Int, filter: [String: Any] = [:]){
        let deleg = ChangeDelegate(channel: channel, id: id)
        
        mongoCollection = user.mongoClient("mongodb-atlas").database(named: database).collection(withName: collection)
        stream = mongoCollection?.watch(matchFilter: filter.bsonConvert(), delegate: deleg)
        
        // Initialize global parameter
        delegate = deleg
    }

    override func unRegister(){
        stream?.close()
    }
}


fileprivate class ChangeDelegate: ChangeEventDelegate {
    init(channel: FlutterMethodChannel?, id: Int){
        self.channel = channel
        self.id = id
    }
    
    var channel: FlutterMethodChannel?
    var id: Int
    func changeStreamDidOpen(_ changeStream: ChangeStream) {
        
    }
    
    func changeStreamDidClose(with error: Error?) {
        
    }
    
    func changeStreamDidReceive(error: Error) {
        
    }
    
    func changeStreamDidReceive(changeEvent: AnyBSON?) {
        var result = [String: Any?]()
        var operationType: String?
        changeEvent?.documentValue?.forEach({(key, value) in
            let doc = value?.documentValue
            if key == "fullDocument", let document = doc?.presentableDictionary{
                result = document
            }
            
            if key == "operationType"{
                operationType = value?.stringValue
            }
        })
        
        if result.keys.count > 0, let operationType = operationType?.outOperationType{
            var out = [String: Any?]()
            out[operationType] = [[0: result]]
            out["id"] = id

            channel?.invokeMethod("change", arguments: out)
        }
    }
}

fileprivate extension RealmSwift.Document{
    var presentableDictionary: [String: Any?]{
        get{
            var result = [String: Any]()
            self.forEach { (key: String, value: AnyBSON?) in
                result[key] = value?.presentableValue
            }
            return result
        }
    }
}


fileprivate extension AnyBSON{
    var presentableValue: Any?{
        switch self{
        case .double:
            return self.doubleValue
        case .int32:
            return self.int32Value
        case .int64:
            return self.int64Value
        case .bool:
            return self.boolValue
        case .datetime:
            return self.dateValue
        default:
            return self.stringValue
        }
    }
    
     init(value: Any){
        switch value {
        case let val as Int:
           self = AnyBSON(val)
        case let val as Int32:
            self = AnyBSON(val)
        case let val as Int64:
            self = AnyBSON(val)
        case let val as Double:
            self = AnyBSON(val)
        case let val as String:
            self = AnyBSON(val)
        case let val as Data:
            self = AnyBSON(val)
        case let val as Date:
            self = AnyBSON(val)
        case let val as Decimal128:
            self = AnyBSON(val)
        case let val as ObjectId:
            self = AnyBSON(val)
        case let val as Document:
            self = AnyBSON(val)
        case let val as Array<AnyBSON?>:
            self = AnyBSON(val)
        case let val as Bool:
            self = AnyBSON(val)
        default:
            self = .null
        }
        
    }

}




fileprivate extension String{
    var outOperationType: String? {
        switch self {
        case "insert":
            return NotifieParent.insertKey
        case "delete":
            return NotifieParent.deleteKey
        case "update":
            return NotifieParent.modifieKey
        default:
            return nil
        }
    }
    
}

fileprivate extension Dictionary where Key == String{
    func bsonConvert() -> [String: AnyBSON]{
        var out = [String: AnyBSON]()
        self.forEach { (key: String, value: Any) in
            out[key] = AnyBSON(value: value)
        }
        return out
    }
}
