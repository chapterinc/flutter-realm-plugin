//
//  DocumentAddition.swift
//  flutterrealm_light
//
//  Created by Grigori on 8/2/21.
//

import Foundation
import RealmSwift

extension RealmSwift.Document{
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


extension AnyBSON{
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


extension Dictionary where Key == String{
    func bsonConvert() -> [String: AnyBSON]{
        var out = [String: AnyBSON]()
        self.forEach { (key: String, value: Any) in
            switch value{
            case let val as Array<[String: Any]>:
                out[key] = AnyBSON(val.map { AnyBSON($0.bsonConvert()) })
            case let val as [String: Any]:
                out[key] =  AnyBSON(val.bsonConvert())
            case let val as [Any]:
                out[key] = AnyBSON(val.map { AnyBSON(value: $0) })
            default:
                out[key] = AnyBSON(value: value)
            }
        }
        return out
    }
}
