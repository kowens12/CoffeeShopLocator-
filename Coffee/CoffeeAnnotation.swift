//
//  CoffeeAnnotation.swift
//  Coffee
//
//  Created by Brian J Glowe on 12/5/15.
//  Copyright © 2015 Brian Glowe. All rights reserved.
//

import Foundation
import MapKit

class CoffeeAnnotation: NSObject, MKAnnotation {
// simply & quickly, the CoffeeAnnotation class inherits from NSObject and implements to the MKAnnotation protocol
    
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    

}