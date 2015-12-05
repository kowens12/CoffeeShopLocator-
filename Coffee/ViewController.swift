//
//  ViewController.swift
//  Coffee
//
//  Created by Brian J Glowe on 12/4/15.
//  Copyright © 2015 Brian Glowe. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView?
    
    var locationManager: CLLocationManager?
    let distanceSpan:Double = 500
    
    var lastLocation:CLLocation?
    var venues: Results<Venue>?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let mapView = self.mapView {
            mapView.delegate = self
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        if locationManager == nil {
            locationManager = CLLocationManager()
            
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 50 // Don't send location updates with a distance smaller than 50 meters between them
            locationManager!.startUpdatingLocation()
        }
    }
/* we need to be sure we have configured the token to receive permission to use the user's location
THIS is performed in the plist, first add the NSLocationAlwaysUsageDescription row and add a string to prompt the user. */
    
    //First, the method signature is locationManager:didUpdateToLocation:fromLocation. The method uses named parameters, which means that the name of the parameter (variable inside the method) is different from the argument used when calling the method. In short, the method has 3 parameters: the location manager that called the method, the new GPS location, and the old GPS location
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        //Inside the method, first self.mapView is unwrapped using optional binding. When self.mapView is not nil, mapView now contains the unwrapped non-optional value, and the if-statement is executed
        if let mapView = self.mapView {
            //In the if-statement, a region is calculated from the new GPS coordinate and the distanceSpan we created earlier. Technically, it creates a rectangular region of 500 by 500 meters with the newLocation coordinate in the center
            let region = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, distanceSpan, distanceSpan)
            //Finally, it calls setRegion on the map view. The named parameter animated is set to true, so the region change is animated. In other words: the map will pan and zoom so it shows the map for the user’s location and 500×500 square meter around it
            mapView.setRegion(region, animated: true)
        }
    }
    
    func refreshVenues(location: CLLocation?, getDataFromFoursquare: Bool = false) {
        if location != nil {
            lastLocation = location
        }
        if let location = lastLocation {
            if getDataFromFoursquare == true {
                CoffeeAPI.sharedInstance.getCoffeeShopsWithLocation(location)
            }
            let realm  = try! Realm() // first we reference Realm
            
            venues = realm.objects(Venue) // Next, we request all Realm objects of class Venue and append it to an array of Venues
            
            for venue in venues! { // The, we loop through the array of venues to annotate their locations to the map
                let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
            
                mapView?.addAnnotation(annotation)
            }
        }
    }
    
    // the following code ensures the annotations added to the map are actually shown
    // it is similar to the way a TBView displays content in a cell.  It reauses the cells / annotations
    // as the user moves across the MapView
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKindOfClass(MKUserLocation) { // first, we check the annotation is NOT the user blip
            return nil
        }
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier("annotationIdentifier") // Next, we dequeue an annotation / pin
        
        if view == nil { // but if no pin was dequeued, lets created a new pin / annotation
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier")
        }
        view?.canShowCallout = true // Then, allow the pins to show a callout to display information
        
        return view // finally, return the view so that it can be displayed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
































