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

