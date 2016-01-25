//
//  Pin.swift
//  VirtualTourist_EM
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit
import MapKit

class Pin: NSObject ,MKAnnotation{
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let totalPages = "totalPages"
    }
    
    var latitude : Double
    var longitude : Double
    var totalPages: NSNumber?
    
    var title: String? = "Press To View Photo album"
    var subtitle: String? = "Flicker Area Pictures"

    
    init(dictionary: [String : AnyObject]) {
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double

    }

    // MARK - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
        didChangeValueForKey("coordinate")
    }
    }

