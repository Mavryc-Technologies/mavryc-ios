//
//  Trip.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import CoreLocation

class Trip: NSObject {
    
    //var departureAirport: AirportLocation?
    //var arrivalAirport: AirportLocation?
    
    var flights: [FlightInfo] = []
    
    func totalPrice() -> String? {
        return "$14,775"
    }
}
