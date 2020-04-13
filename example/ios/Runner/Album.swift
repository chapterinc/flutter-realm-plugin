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
    @objc dynamic var id: String = ""
    @objc dynamic var coverPhotoId: String?
    
    @objc dynamic var name: String?
    @objc dynamic var flag: String?
    @objc dynamic var type: String?
    @objc dynamic var tag: String?

    @objc dynamic var isSorted: Bool = false
    @objc dynamic var isTrash: Bool = false
    @objc dynamic var isFake: Bool = false
    @objc dynamic var isFavorite: Bool = false

    let createdTimestamp = RealmOptional<Double>()
    let timestamp = RealmOptional<Double>()
    
    let photos = LinkingObjects(fromType: Photo.self, property: "albums")

    override public class func primaryKey() -> String? {
        return "id"
    }
}
