//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gustavo on 10/1/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    convenience init(latitude:Double, longitude:Double, page:Int=1, context:NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context){
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.page = Int16(page)
        }else{
            fatalError("Unable to find entity name!")
        }
    }
    
    
    
}
