//
//  PhotoFetchController.swift
//  VirtualTourist
//
//  Created by Gustavo on 9/30/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import CoreData



extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate{
   
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
        case .insert:
            collectionView?.insertSections(set)
        case .delete:
            collectionView?.deleteSections(set)
        default:
            // irrelevant in our case
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch(type) {
        case .insert:
            collectionView?.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView?.deleteItems(at: [newIndexPath!])
        case .update:
            collectionView?.reloadItems(at: [newIndexPath!])
        case .move:
            collectionView?.insertItems(at: [newIndexPath!])
            collectionView?.deleteItems(at: [newIndexPath!])
        }
    }

   

}
