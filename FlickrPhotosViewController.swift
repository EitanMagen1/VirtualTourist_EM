//
//  FlickrPhotosViewController.swift
//  VirtualTourist_EM
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "FlickerCell"

class FlickrPhotosViewController: UIViewController ,UICollectionViewDataSource , UICollectionViewDelegate , MKMapViewDelegate {
    
    var photos : [Photo] = []
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
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.hidden = true
        mapview.delegate = self
        self.collectionView2.dataSource = self
        self.collectionView2.delegate = self
        
        self.mapview.delegate = self
        self.mapview.userInteractionEnabled = false
        self.mapview.region.center = pin!.coordinate
        self.mapview.region.span = MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
        self.mapview.addAnnotation(pin!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView2!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.downloadingCount == 0 {
            self.newDownloadButton.hidden = false
            self.enableUserInteraction = true
        }
        
        
        loadData()
        
    }
    
    @IBAction func newDownloadTouchUpInside(sender: AnyObject) {
        
        photos = []
        
        loadData()
    }

    
    func loadData() {
        self.newDownloadButton.hidden = true
        self.enableUserInteraction = false
        self.downloadingCount = Int(FlickrClient.Constants.PER_PAGE)!
        indicator.hidden = false
        FlickrClient.sharedInstance().getPhotos(pin) { (success, result, totalPhotos, totalPages, errorString) in
            if (success == true) {
                print("\(totalPhotos) photos have been found!")
                
                // Parse the array of photo dictionaries
                let _ = result!.map() { (dictionary: [String : AnyObject]) -> Photo in
                    
                    let photo = Photo()
                    photo.imageURL = dictionary[FlickrClient.Constants.EXTRAS] as? String
                    photo.pin = self.pin
                    self.photos.append(photo)
                    return photo
                }
                
                // Update the collection view on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView2.reloadData()
                }
            } else {
                self.presentError("Finding photos error! \(errorString)")
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        let photo = photos[indexPath.row]
        
       configureCell(cell, photo: photo)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (self.enableUserInteraction) {

        photos.removeAtIndex(indexPath.row)
        dispatch_async(dispatch_get_main_queue()) {
            self.collectionView2.reloadData()
        }
        }
    }

    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var cellImage = UIImage(named: "posterPlaceHolder")
        
        cell.imageView!.image = nil
        self.downloadingCount--
        if self.downloadingCount == 0 {
            self.newDownloadButton.hidden = false
            self.indicator.hidden = true
            self.enableUserInteraction = true
        }

        // Set the Album Image
        if photo.imageURL == nil || photo.imageURL == "" {
            cellImage = UIImage(named: "noImage")
        } else if photo.albumImage != nil {
            cellImage = photo.albumImage
        } else { // This is the interesting case. The pin has an image name, but it is not downloaded yet.
            
            FlickrClient.sharedInstance().getPhoto(NSURL(string: photo.imageURL!)!) { (success, result, errorString) in
                if (success == true) {
                    // update the model, so that the infrmation gets cashed
                    photo.albumImage = result
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView!.image = result
                        
                        }

                } else {
                    self.presentError("\(errorString)")
                }
            }
        }
        
        cell.imageView!.image = cellImage
    }
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.draggable = true
            pinView!.pinTintColor = MKPinAnnotationView.purplePinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .InfoDark)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}
