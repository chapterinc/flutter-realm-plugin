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
    @objc dynamic var id: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var username: String = ""
    
    @objc dynamic var email: String?
    @objc dynamic var phone: String?

    @objc dynamic var countryCode: String?
    @objc dynamic var emoji: String?
    @objc dynamic var firstName: String?
    @objc dynamic var surname: String?

    @objc dynamic var recentsPhotosSortedPartsCount: Int = 0
    @objc dynamic var totalMediaSortedCount: Int = 0
    @objc dynamic var totalMediaCount: Int = 0
    @objc dynamic var totalMediaKept: Int = 0
    @objc dynamic var albumsCount: Int = 0
    @objc dynamic var keptPercent: Double = 0
    @objc dynamic var sortedPercent: Double = 0
    @objc dynamic var isMe: Bool = true
    @objc dynamic var photo: Photo?

    // Dates
    let birthDayTimestamp = RealmOptional<Int32>()
    let createdDateTimestamp = RealmOptional<Int32>()
    let recentsSortedDateTimestamp = RealmOptional<Int32>()
    let recentsNewPhotoDateTimestamp = RealmOptional<Int32>()
    
    override public class func primaryKey() -> String? {
        return "id"
    }
}


