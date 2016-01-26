//
//  Photo.swift
//  VirtualTourist
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit


class Photo  {
    
    struct Keys {
        static let Id = "id"
        static let Title = "title"
        static let ImageURL = "url_m"
        static let ImagePath = "imageFilePath"
    }
    
     var title: String?
     var imageURL: String?
     var imagePath: String?
     var pin: Pin?
    
    var albumImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(getFilename(NSURL(string: imageURL!)!))
        }
        
        set {
            //print("DEBUG: \(newValue) \(imageURL)")
            if let imageURL = self.imageURL {
                FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: getFilename(NSURL(string: imageURL)!))
                
            }
        }
    }
    func getFilename(photoURL: NSURL) -> String {
        let components = photoURL.pathComponents
        return components!.last!
    }

         
    
}

