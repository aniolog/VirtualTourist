//
//  PinViewController.swift
//  VirtualTourist
//
//  Created by Carlos Lozano on 9/24/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let uiLargePress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation(gestureRecognizer:)))
        
        uiLargePress.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(uiLargePress)
        
        if let preferences:[String: Double] = UserDefaults.standard.object(forKey: "preferences") as? [String: Double]{
            
            let center = CLLocationCoordinate2D(latitude: preferences["centerLatitude"]!, longitude: preferences["centerLongitude"]!)
            
            let span = MKCoordinateSpan(latitudeDelta:preferences["deltaLatitude"]!, longitudeDelta:  preferences["deltaLongitude"]!)
            
            let saveRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(saveRegion, animated: true)
        }
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let app = UIApplication.shared
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveUserDefaults(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    
    
    func saveUserDefaults(notification: NSNotification) {
        let centerLongitude = mapView.region.center.longitude
        let centerLatitude = mapView.region.center.latitude
        
        let deltaLongitude = mapView.region.span.longitudeDelta
        let deltaLatitude = mapView.region.span.latitudeDelta
    
        let preferences = [
            "centerLongitude": centerLongitude,
            "centerLatitude": centerLatitude,
            "deltaLongitude": deltaLongitude,
            "deltaLatitude": deltaLatitude
        
        ]
        
        UserDefaults.standard.set(preferences, forKey: "preferences")
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        performSegue(withIdentifier: "location", sender: self)
    }
    
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinates
        mapView.addAnnotation(annotation)
        
    }
    
    
    
}
