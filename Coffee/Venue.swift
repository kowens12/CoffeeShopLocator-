//
//  Venue.swift
//  Coffee
//
//  Created by Brian J Glowe on 12/4/15.
//  Copyright © 2015 Brian Glowe. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Venue: Object {
    // declaring a property to be dynamic allows for the property to be accessed via the Obj-C runtime. In Swift 2.0
    dynamic var id: String = ""
    dynamic var name: String = ""
    
    dynamic var latitude: Float = 0
    dynamic var longitude: Float = 0
    dynamic var address: String = ""
    
    var coordinate:CLLocation {
        return CLLocation(latitude: Double(latitude), longitude: Double(longitude));
    }
    
    override static func primaryKey() -> String?
    {
        return "id";
    }
}
