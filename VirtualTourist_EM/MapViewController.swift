//
//  MapViewController.swift
//  VirtualTourist_EM
//
//  Created by Lauren Efron on 24/01/2016.
//  Copyright © 2016 Eitan_Magen. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController ,MKMapViewDelegate{

    static let sheredInstance = MapViewController()

    @IBOutlet weak var mapView: MKMapView!
    var pinInFocus: Pin?
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self

        // add long press gesture to the map
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 0.6
        mapView.addGestureRecognizer(longPress)
    }
    
    let regionRadius: CLLocationDistance = 50000
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    
    func dropPin(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        switch(gestureRecognizer.state){
        case UIGestureRecognizerState.Began:
            var locationDictionary = [String : AnyObject]()
            locationDictionary[Pin.Keys.Latitude] = newCoord.latitude
            locationDictionary[Pin.Keys.Longitude] = newCoord.longitude
            self.pinInFocus = Pin(dictionary: locationDictionary)
            mapView.addAnnotation(self.pinInFocus!)
        case UIGestureRecognizerState.Changed:
            self.pinInFocus!.setCoordinate(newCoord)
        case UIGestureRecognizerState.Ended:
            // moving the map center to follow the new pin
            centerMapOnLocation(newCoord)
           // CoreDataStackManager.sharedInstance.saveContext()
        default:
            return
            
        }
        // save the pin location
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
            
           // if newState == MKAnnotationViewDragState.Ending {
         //       CoreDataStackManager.sharedInstance().saveContext()
            //}
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
    // MARK: - MKMapViewDelegate
    // waiting for the info on the pin notification label to be pressed , send pin location to flicker and move to collection view screen
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FlickrPhotosViewController") as! FlickrPhotosViewController
            let annotation = view.annotation as! Pin
            controller.pin = annotation
            self.navigationController!.pushViewController(controller, animated: true)
            
        }
    }

}

