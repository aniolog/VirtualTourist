//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Gustavo on 10/1/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var page: Int16
    @NSManaged public var photos: NSSet?

}
