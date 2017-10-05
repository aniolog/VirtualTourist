//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gustavo on 10/1/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var url: String?
    @NSManaged public var data: Data?
    @NSManaged public var pin: Pin?

}
