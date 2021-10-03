//
//  Photo.swift
//  Sorted
//
//  Created by Grigori on 4/9/19.
//  Copyright © 2019 Sorted. All rights reserved.
//

import Foundation
import RealmSwift

public final class Photo: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var burstIdentifier: String?
    @objc dynamic var mediaType: String?
    @objc dynamic var city: String?
    @objc dynamic var country: String?
    @objc dynamic var state: String?

    @objc dynamic var subType: Int = 0
    @objc dynamic var type: Int = 1

    let isUploaded = RealmProperty<Bool?>()
    let isTrashed = RealmProperty<Bool?>()
    let isSorted = RealmProperty<Bool?>()

    @objc dynamic var photoDetail: PhotoDetail?
    @objc dynamic var userPhotoDetail: PhotoDetail?

    let userId = RealmProperty<Int?>()

    let sortIndex = RealmProperty<Double?>()
    let duration = RealmProperty<Double?>()
    let pixelWidth = RealmProperty<Int?>()
    let pixelHeight = RealmProperty<Int?>()
    let startTime = RealmProperty<Double?>()
    let endTime = RealmProperty<Double?>()
    let timeScale = RealmProperty<Int?>()
    let year = RealmProperty<Int?>()
    let month = RealmProperty<Int?>()
    let latitude = RealmProperty<Double?>()
    let longitude = RealmProperty<Double?>()

    // Dates
    let createdDateTimestamp = RealmProperty<Int32?>()
    let creationDateTimestamp = RealmProperty<Int32?>()
    let sortedDateTimeStamp = RealmProperty<Int32?>()
    let putBackDateTimeStamp = RealmProperty<Int32?>()
    let modificationDate = RealmProperty<Int32?>()

    var albums = List<Album>()

    override public class func primaryKey() -> String? {
        return "_id"
    }
}
