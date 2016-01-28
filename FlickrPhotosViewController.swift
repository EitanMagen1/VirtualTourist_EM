//
//  FlickrPhotosViewController.swift
//  VirtualTourist_EM
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit
import MapKit
import CoreData


private let reuseIdentifier = "FlickerCell"
// core data step 8 add NSFetchedResultsControllerDelegate
class FlickrPhotosViewController: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate , MKMapViewDelegate , NSFetchedResultsControllerDelegate {
    
    // var photos : [Photo] = [] // core data step 4 removing the array
    var pin: Pin!
    var latitudeDelta: Double = 0.1
    var longitudeDelta: Double = 0.1
    var downloadingCount: Int = 0
    var enableUserInteraction = false
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!
    
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var collectionView2: UICollectionView!
    @IBOutlet weak var newDownloadButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidden = true
        mapview.delegate = self
        self.collectionView2.dataSource = self
        self.collectionView2.delegate = self
        
        self.mapview.delegate = self
        self.mapview.userInteractionEnabled = false
        self.mapview.region.center = pin!.coordinate
        self.mapview.region.span = MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
        self.mapview.addAnnotation(pin!)
        
                // Register cell classes
       // self.collectionView2!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // core data step 9
        fetchedResultsController.delegate = self
        // core data Step 2: Start the fetch by invoking performFetch
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
       

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        for photo in fetchedResultsController.fetchedObjects as! [Photo]{
            if (photo.albumImage == nil) {
                self.downloadingCount++
            }
            
        }
        if self.downloadingCount == 0 {
            self.newDownloadButton.hidden = false
            self.enableUserInteraction = true
        }
        
        if (pin.photos!.isEmpty) {
            loadData()
        }
        
    }
    
    @IBAction func newDownloadTouchUpInside(sender: AnyObject) {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo]{
            FlickrClient.Caches.imageCache.removeImage(NSURL(string: photo.imageURL!)!.lastPathComponent!)
            pin.deletePhoto(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        loadData()
    }
    
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var cellImage = UIImage(named: "posterPlaceHolder")
        
        cell.imageView!.image = nil
        activityIndicator.hidden = true
        
        // Set the Album Image
        if photo.imageURL == nil || photo.imageURL == "" {
            cellImage = UIImage(named: "noImage")
        } else if photo.albumImage != nil {
            cellImage = photo.albumImage
        } else { // This is the interesting case. The pin has an image name, but it is not downloaded yet.
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            FlickrClient.sharedInstance().getPhoto(NSURL(string: photo.imageURL!)!) { (success, result, errorString) in
                if (success == true) {
                    // update the model, so that the infrmation gets cashed
                    photo.albumImage = result
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imageView!.image = result
                        
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        
                        self.downloadingCount--
                        if self.downloadingCount == 0 {
                            self.newDownloadButton.hidden = false
                            self.enableUserInteraction = true
                        }
                    })
                } else {
                    print(errorString)
                }
            }
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //cell.taskToCancelifCellIsReused = task
        }
        
        cell.imageView!.image = cellImage
    }
    
    
    func loadData() {
        self.newDownloadButton.hidden = true
        self.enableUserInteraction = false
        self.downloadingCount = Int(FlickrClient.Constants.PER_PAGE)!
        
        FlickrClient.sharedInstance().getPhotos(pin) { (success, result, totalPhotos, totalPages, errorString) in
            if (success == true) {
                print("\(totalPhotos) photos have been found!")
                //print(result)
                
                // Parse the array of photo dictionaries
                let _ = result!.map() { (dictionary: [String : AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                    photo.pin = self.pin
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    return photo
                }
                
                // Update the collection view on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView2.reloadData()
                }
            } else {
                print("Finding photos error!")
            }
        }
    }
    
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // lazy fetchedResultsController property
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (self.enableUserInteraction) {
            // Delete image
            let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
            self.pin.deletePhoto(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
       // print("Collection controllerWillChangeContent")
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
            case .Insert:
                //print("insert")
                //self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
                insertedIndexPaths.append(newIndexPath!)
            case .Delete:
                //print("delete")
                //self.collectionView.deleteItemsAtIndexPaths([indexPath!])
                deletedIndexPaths.append(indexPath!)
            case .Update:
                //print("uptade")
                //self.collectionView.reloadItemsAtIndexPaths([indexPath!])
                updatedIndexPaths.append(indexPath!)
            default:
                break
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Perform updates into the collectionView
      //  print("Collection controllerDidChangeContent")
        collectionView2.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView2.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView2.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView2.reloadItemsAtIndexPaths([indexPath])
            }
            }, completion: nil)
    }
}
