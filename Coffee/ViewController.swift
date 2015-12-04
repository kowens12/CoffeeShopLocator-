//
//  ViewController.swift
//  Coffee
//
//  Created by Brian J Glowe on 12/4/15.
//  Copyright © 2015 Brian Glowe. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var mapView: MKMapView?
    
    var locationManager: CLLocationManager?
    let distanceSpan:Double = 500

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

