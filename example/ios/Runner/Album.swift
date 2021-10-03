//
//  AlbumRealm.swift
//  Sorted
//
//  Created by Grigori on 4/9/19.
//  Copyright © 2019 Sorted. All rights reserved.
//

import Foundation
import RealmSwift

public final class Album: Object {
    @objc dynamic var _id: String = ""
    @objc dynamic var coverPhotoId: String?

    @objc dynamic var name: String?
    @objc dynamic var type: String?

    @objc dynamic var isSorted: Bool = false

    @objc dynamic var tag: Tag?

    let createdTimestamp = RealmProperty<Int32?>()
    let timestamp = RealmProperty<Int32?>()

    let photos = LinkingObjects(fromType: Photo.self, property: "albums")

    override public class func primaryKey() -> String? {
        return "_id"
    }
}
