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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var tableView: UITableView?
    
    var locationManager: CLLocationManager?
    let distanceSpan:Double = 500
    
    var lastLocation:CLLocation?
    var venues: [Venue]?

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("onVenuesUpdated:"), name: API.notifications.venuesUpdated, object: nil)
        //^^ this will tell the notification center that self is listening to a notification of type API.notifications.venuesUpdated
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let mapView = self.mapView {
            mapView.delegate = self
        }
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 50 // Don't send location updates with a distance smaller than 50 meters between them
            locationManager!.startUpdatingLocation()
        }
        
        if let tableView = self.tableView {
            tableView.delegate = self
            tableView.dataSource = self
        }
        
    }
    
    func onVenuesUpdated(notification: NSNotification) {
        refreshVenues(nil)
    }
    
    // MARK: Location Manager Methods
    
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
            
            refreshVenues(newLocation, getDataFromFoursquare: true)
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
            // the following 3 lines are replaced by the code starting after commented out
//            let realm  = try! Realm() // first we reference Realm
//            
//            venues = realm.objects(Venue) // Next, we request all Realm objects of class Venue and append it to an array of Venues

            let (start, stop) = calculateCoordinatesWithRegion(location)
            
            let predicate = NSPredicate(format: "latitude < %f AND latitude  %f AND longitude > %f AND longitude < %f", start.latitude, stop.latitude, start.longitude, stop.longitude)
            
            let realm = try! Realm()
            
            venues = realm.objects(Venue).filter(predicate).sort {
                location.distanceFromLocation($0.coordinate) < location.distanceFromLocation($1.coordinate)
            }
            
            
            for venue in venues! { // The, we loop through the array of venues to annotate their locations to the map
                let annotation = CoffeeAnnotation(title: venue.name, subtitle: venue.address, coordinate: CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)))
            
                mapView?.addAnnotation(annotation)
            }
        }
        tableView?.reloadData()
    }
    
    func calculateCoordinatesWithRegion(location: CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
        
        var start: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var stop: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        start.latitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        stop.latitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
        stop.longitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
        
        return (start, stop)
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

    // MARK: Table View delegate protocol methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues?.count ?? 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cellIdentifier")
        }
        
        if let venue = venues?[indexPath.row] {
            cell!.textLabel?.text = venue.name
            cell?.detailTextLabel?.text = venue.address
        }
        
        return cell!
    }
    
    // this method centers the map view to the pin / annotation selected in the tableview
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let venue = venues?[indexPath.row] {
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: Double(venue.latitude), longitude: Double(venue.longitude)), distanceSpan, distanceSpan)
                mapView?.setRegion(region, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
































