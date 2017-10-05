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

class PinViewController: UIViewController, MKMapViewDelegate,  NSFetchedResultsControllerDelegate {

    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
   
    var selectedPin: Pin? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        let uiLargePress = UILongPressGestureRecognizer(target: self, action: #selector(self.addAnnotation(gestureRecognizer:)))
        
        mapView.addGestureRecognizer(uiLargePress)
        
        if let preferences:[String: Double] = UserDefaults.standard.object(forKey: "preferences") as? [String: Double]{
            
            let center = CLLocationCoordinate2D(latitude: preferences["centerLatitude"]!, longitude: preferences["centerLongitude"]!)
            
            let span = MKCoordinateSpan(latitudeDelta:preferences["deltaLatitude"]!, longitudeDelta:  preferences["deltaLongitude"]!)
            
            let saveRegion = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(saveRegion, animated: true)
        }
        self.navigationController?.isNavigationBarHidden = true
       
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true),
                              NSSortDescriptor(key: "longitude", ascending: true)]
        
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        let app = UIApplication.shared
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveUserDefaults(notification:)), name: NSNotification.Name.UIApplicationWillResignActive, object: app)
        
        DispatchQueue.main.async {
            do{
                let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                
                let results = try self.fetchedResultsController?.managedObjectContext.fetch(fr)
                let pins = results as! [Pin]
                var pinAnnotations = [VTAnnotation]()
                for pin in pins{
                    let annotation = VTAnnotation(pin: pin)
                    annotation.coordinate =  CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                    pinAnnotations.append(annotation)
                }
                self.mapView.addAnnotations(pinAnnotations)
            }catch{
                fatalError("unable to fetch pins")
            }
            
        }
      
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
    
        let vtAnnotation = view.annotation as! VTAnnotation
        let photoAlbumVC: PhotoAlbumViewController = storyboard?.instantiateViewController(withIdentifier: "album") as! PhotoAlbumViewController
        photoAlbumVC.pin =  vtAnnotation.pin
        self.navigationController?.pushViewController(photoAlbumVC, animated: true)
        
    }
    
    
    func addAnnotation(gestureRecognizer:UIGestureRecognizer) {
        
        if gestureRecognizer.state == .began{
            
            let locationPoint = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(locationPoint, toCoordinateFrom: mapView)
            
            let pin: Pin = Pin(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude, page: 0, context: (fetchedResultsController?.managedObjectContext)!)
            
            let annotation = VTAnnotation(pin: pin)
            annotation.coordinate = locationCoordinate
            mapView.addAnnotation(annotation)
            
            DispatchQueue.main.async {
                do{
                    try self.delegate.stack.saveContext()
                }catch{
                    fatalError("unable to save pin")
                }
            }
        
        }
    }
    
    
    
    
    
    
}
