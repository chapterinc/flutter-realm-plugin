//
//  PhotoRealm.swift
//  Sorted
//
//  Created by Grigori on 4/9/19.
//  Copyright © 2019 Sorted. All rights reserved.
//

import Foundation
import RealmSwift

public final class Photo: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var burstIdentifier: String?
    @objc dynamic var mediaType: String?
    @objc dynamic var subType: Int = 0
    @objc dynamic var type: Int = 1
    
    @objc dynamic var isUploaded: Bool = false
    @objc dynamic var isTrashed: Bool = false
    @objc dynamic var isSorted: Bool = false
//    dynamic var photoDetail: PhotoDetailRealm?
//    dynamic var userPhotoDetail: PhotoDetailRealm?
    @objc dynamic var userId: String?
    
    let sortIndex = RealmOptional<Double>()
    let duration = RealmOptional<Double>()
    let pixelWidth = RealmOptional<Int>()
    let pixelHeight = RealmOptional<Int>()
    let startTime = RealmOptional<Double>()
    let endTime = RealmOptional<Double>()
    let timeScale = RealmOptional<Int>()
    let year = RealmOptional<Int>()
    let month = RealmOptional<Int>()

    // Dates
    let createdDateTimestamp = RealmOptional<Int32>()
    let creationDateTimestamp = RealmOptional<Int32>()
    let sortedDateTimeStamp = RealmOptional<Int32>()
    let modificationDate = RealmOptional<Int32>()

    override public class func primaryKey() -> String? {
        return "id"
    }
}
