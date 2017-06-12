//
//  AirportLocation.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import CoreLocation

class AirportLocation {

    let location: CLLocation!
    let threeLetterCode: String!
    let airportName: String!
    let airportCity: String!
    let airportCountry: String!
    
    init(location: CLLocation, code: String, name: String, city: String, country: String) {
        self.location = location
        self.threeLetterCode = code
        self.airportName = name
        self.airportCity = city
        self.airportCountry = country
    }
    
}
