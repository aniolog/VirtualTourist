//
//  VTAnnotation.swift
//  VirtualTourist
//
//  Created by Gustavo on 9/28/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import MapKit


class VTAnnotation: NSObject, MKAnnotation {
    
    var pin: Pin
    var coordinate: CLLocationCoordinate2D
    
    init(pin: Pin) {
        self.pin = pin
        self.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        super.init()
    }
}
