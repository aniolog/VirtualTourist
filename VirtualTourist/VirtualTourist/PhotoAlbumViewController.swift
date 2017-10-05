//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Carlos Lozano on 9/24/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var pin: Pin?
    
    var photos:[Photo]? = [Photo]()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.navigationController?.isNavigationBarHidden = false
        self.mapView.addAnnotation(VTAnnotation(pin: pin!))
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        request.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin!])
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
       
        do{
          photos =  try (fetchedResultsController?.managedObjectContext.fetch(request)) as! [Photo]
            print(photos?.count)
            if photos?.count == 0 {
                loadPhotos()
            }
            
            
        }catch{
        
        }
      
        
    }
    
    func loadPhotos(){
        Client.shared.getImageByLocation(pin: pin!){
            (photos) in
            guard let photos = photos, photos != nil else{
                return
            }
            for photoUrl in photos{
                let photoObj = Photo(url: photoUrl, context: self.delegate.stack.context)
                photoObj.pin = self.pin
            }
            print(photos)
            DispatchQueue.main.async {
                do{
                   try self.fetchedResultsController?.managedObjectContext.save()
                   try self.fetchedResultsController?.performFetch()
                    self.collectionView.reloadData()
                }catch {
                    fatalError("unable to save")
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        do {
            
            try fetchedResultsController?.performFetch()
            return (fetchedResultsController?.fetchedObjects?.count)!
            
        }catch{
        
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        do{
            let photo = fetchedResultsController?.object(at: indexPath) as! Photo
            fetchedResultsController?.managedObjectContext.delete(photo)
            collectionView.reloadData()
            try fetchedResultsController?.managedObjectContext.save()
        }catch{
            fatalError("unable to send")
        }
    }
   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! VTPhotoViewCell
        cell.imageView.image = UIImage(named: "thumbnail")
        if(photo.data == nil){
            DispatchQueue.main.async {
                
                Client.shared.getPhotoData(photo: photo, context: (self.fetchedResultsController?.managedObjectContext)!){
                    () in
                    let image = UIImage(data: photo.data!)
                    cell.imageView.image = image
                }
                
            }
        }
        else{
            cell.imageView.image = UIImage(data: photo.data!)
        }
        
        return cell
    }
    
    
    @IBAction func dismiss(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func loadMorePhotos(_ sender: Any) {
       pin?.page = (pin?.page)! + 1
        
        do {
            for photo in (fetchedResultsController?.fetchedObjects)! {
                fetchedResultsController?.managedObjectContext.delete(photo as! NSManagedObject)
            }
            try fetchedResultsController?.managedObjectContext.save()
        }catch{
        
        }
        collectionView.reloadData()
        loadPhotos()
        
        
    }
    
    
}
