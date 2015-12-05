//
//  CoffeeAPI.swift
//  Coffee
//
//  Created by Brian J Glowe on 12/4/15.
//  Copyright © 2015 Brian Glowe. All rights reserved.
//

import Foundation
import QuadratTouch
import MapKit
import RealmSwift

struct API {
    struct notifications {
        static let venuesUpdated = "venues updated"
    }
}

class CoffeeAPI {
    static let sharedInstance = CoffeeAPI()
    var session: Session?
    
    init() {
        // Initialize the foursquare client
        let client = Client(clientID: "XQRJ3NSYZ2CQELTULRCN10L22KU2JQW1AGXFPLZEOXALCXZG", clientSecret: "5KAFSHVL3D12CB2RVOEC04XAI3CXY0HOS2TDFW5TVUPPMVKO", redirectURL: "")
        
        let configuration = Configuration(client: client)
        Session.setupSharedSessionWithConfiguration(configuration)
        
        self.session = Session.sharedSession()
    }

    func getCoffeeShopsWithLocation(location:CLLocation) {
    /* 1. Setup, configuration and start of the API request.
    2. Completion handler of the request (it’s the closure).
    3. “Untangling” of the request result data, and the start of the Realm transaction.
    4. The for-in loop that loops over all the venue data.
    5. The end of the completion handler, it sends a notification.*/
        
        if let session = self.session { //1
            var parameters = location.parameters()
            parameters += [Parameter.categoryId: "4bf58dd8d48988d1e0931735"] // this categoryID is the coffee shop ID in foursquare
            parameters += [Parameter.radius: "2000"]
            parameters += [Parameter.limit: "50"]
            
            // Start a "search", i.e. an async call to Foursquare that should return venue data
            let searchTask = session.venues.search(parameters) {
                    (result) -> Void in // beginning of closure
                    
                    if let response = result.response {
                        if let venues = response["venues"] as? [[String: AnyObject]] {
                            autoreleasepool { // autorelease assists in memory management, simliar to garbage collection
                                    let realm = try! Realm()
                                    // NOTE - try! is apart of Swifts error handling and is not recommended for production environments!!
                                    realm.beginWrite() // beginWrite() is a transaction for writing the files to Realm
                                    
                                    for venue:[String: AnyObject] in venues {
                                        let venueObject:Venue = Venue()
                                        
                                        if let id = venue["id"] as? String {
                                            venueObject.id = id
                                        }
                                        
                                        if let name = venue["name"] as? String {
                                            venueObject.name = name
                                        }
                                        
                                        if  let location = venue["location"] as? [String: AnyObject] {
                                            if let longitude = location["lng"] as? Float {
                                                venueObject.longitude = longitude
                                            }
                                            
                                            if let latitude = location["lat"] as? Float {
                                                venueObject.latitude = latitude
                                            }
                                            
                                            if let formattedAddress = location["formattedAddress"] as? [String] {
                                                venueObject.address = formattedAddress.joinWithSeparator(" ")
                                            }
                                        }
                                        
                                        realm.add(venueObject, update: true)
                                    }
                                    // error handling
                                    do {
                                        try realm.commitWrite()
                                        print("Committing write...")
                                    }
                                    catch (let e) {
                                        print("Y U NO REALM ? \(e)")
                                    }
                            }
                            
                            NSNotificationCenter.defaultCenter().postNotificationName(API.notifications.venuesUpdated, object: nil, userInfo: nil)
                        }
                    }
            } // end of closure
            
            searchTask.start()
        }
    }

}

extension CLLocation {
    func parameters() -> Parameters {
        let ll      = "\(self.coordinate.latitude), \(self.coordinate.longitude)"
        let llAcc   = "\(self.horizontalAccuracy)"
        let alt     = "\(self.altitude)"
        let altAcc  = "\(self.verticalAccuracy)"
        let parameters = [ Parameter.ll:ll, Parameter.llAcc:llAcc, Parameter.alt:alt, Parameter.altAcc:altAcc]
        
        return parameters
    }
}







