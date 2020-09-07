//
//  PhotoDetail.swift
//  Sorted
//
//  Created by Grigori on 3/3/20.
//  Copyright © 2020 Sorted. All rights reserved.
//

import Foundation
import RealmSwift

public final class PhotoDetail: Object {
    @objc dynamic var _id: String = ""

    /// This parameters must be calculated relatively
    /// ``` centerx = realCenterx / containerWidth ```
    @objc dynamic var centerx: Double = 0
    
    /// This parameters must be calculated relatively
    /// ``` centery = realCentery / containerWidth ```
    @objc dynamic var centery: Double = 0
    
    @objc dynamic var rotate: Double = 0
    @objc dynamic var timestamp: Double = 0
    @objc dynamic var zoom: Double = 1

    override public class func primaryKey() -> String? {
        return "_id"
    }
}
