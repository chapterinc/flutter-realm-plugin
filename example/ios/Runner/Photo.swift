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

    let isUploaded = RealmOptional<Bool>()
    let isTrashed = RealmOptional<Bool>()
    let isSorted = RealmOptional<Bool>()

    @objc dynamic var photoDetail: PhotoDetail?
    @objc dynamic var userPhotoDetail: PhotoDetail?

    let userId = RealmOptional<Int>()

    let sortIndex = RealmOptional<Double>()
    let duration = RealmOptional<Double>()
    let pixelWidth = RealmOptional<Int>()
    let pixelHeight = RealmOptional<Int>()
    let startTime = RealmOptional<Double>()
    let endTime = RealmOptional<Double>()
    let timeScale = RealmOptional<Int>()
    let year = RealmOptional<Int>()
    let month = RealmOptional<Int>()
    let latitude = RealmOptional<Double>()
    let longitude = RealmOptional<Double>()

    // Dates
    let createdDateTimestamp = RealmOptional<Int32>()
    let creationDateTimestamp = RealmOptional<Int32>()
    let sortedDateTimeStamp = RealmOptional<Int32>()
    let putBackDateTimeStamp = RealmOptional<Int32>()
    let modificationDate = RealmOptional<Int32>()

    var albums = List<Album>()

    override public class func primaryKey() -> String? {
        return "_id"
    }
}
