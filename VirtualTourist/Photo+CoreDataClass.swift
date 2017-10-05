//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Gustavo on 10/1/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(url:String,context:NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context){
            self.init(entity: ent, insertInto: context)
            self.url = url
            self.data = nil
        }else{
            fatalError("Unable to find entity name!")
        }
    }

    
    
}
