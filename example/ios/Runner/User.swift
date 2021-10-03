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

    let recentsPhotosSortedPartsCount = RealmProperty<Int32?>()
    
    let mediaArchivedCount = RealmProperty<Int32?>()
    let mediaKeptCount = RealmProperty<Int32?>()
 
    @objc dynamic var photo: Photo?

    // Dates
    let birthDayTimestamp = RealmProperty<Int32?>()
    let createdDateTimestamp = RealmProperty<Int32?>()
    let recentsSortedDateTimestamp = RealmProperty<Int32?>()
    let recentsNewPhotoDateTimestamp = RealmProperty<Int32?>()

    override public class func primaryKey() -> String? {
        return "_id"
    }
}


