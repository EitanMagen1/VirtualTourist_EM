//
//  Photo.swift
//  VirtualTourist
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    struct Keys {
        static let Id = "id"
        static let Title = "title"
        static let ImageURL = "url_m"
        static let ImagePath = "imageFilePath"
    }
    
    @NSManaged var title: String?
    @NSManaged var imageURL: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    var albumImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(getFilename(NSURL(string: imageURL!)!))
        }
        
        set {
          //  print("DEBUG: \(newValue) \(imageURL)")
            if let imageURL = self.imageURL {
                FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: getFilename(NSURL(string: imageURL)!))
            }
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as? String
        imageURL = dictionary[Keys.ImageURL] as? String
    }
    
    // before delete this entity delete the image in the FS
    override func prepareForDeletion() {
        // Delete file if possible
        if let imageURL = self.imageURL {
            FlickrClient.Caches.imageCache.removeImage(getFilename(NSURL(string: imageURL)!))
        }
    }
    
    func getFilename(photoURL: NSURL) -> String {
        let components = photoURL.pathComponents
        return components!.last!
    }
    
}
