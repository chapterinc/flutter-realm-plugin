//
//  User.swift
//  Sorted
//
//  Created by Grigori on 4/9/19.
//  Copyright © 2019 Sorted. All rights reserved.
//

import Foundation
import RealmSwift

public final class User: Object {
    @objc dynamic var _id: Int = -1
    @objc dynamic var password: String?
    @objc dynamic var username: String = ""
    @objc dynamic var _partition: String = "hikaru"

    @objc dynamic var isMe: Bool = true

    @objc dynamic var email: String?
    @objc dynamic var phone: String?

    @objc dynamic var phoneDialCode: String?
    @objc dynamic var emoji: String?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?

    let recentsPhotosSortedPartsCount = RealmOptional<Int32>()
    
    let mediaArchivedCount = RealmOptional<Int32>()
    let mediaKeptCount = RealmOptional<Int32>()
 
    @objc dynamic var photo: Photo?

    // Dates
    let birthDayTimestamp = RealmOptional<Int32>()
    let createdDateTimestamp = RealmOptional<Int32>()
    let recentsSortedDateTimestamp = RealmOptional<Int32>()
    let recentsNewPhotoDateTimestamp = RealmOptional<Int32>()

    override public class func primaryKey() -> String? {
        return "_id"
    }
}


