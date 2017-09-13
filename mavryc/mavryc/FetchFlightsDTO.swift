//
//  FetchFlightsDTO.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

struct FetchFlightsDTO {
    
    var origin: String?
    var destination: String?
    var departureDateTime: String?
    var arrivalDateTime: String?
    var jetServiceType: String?
    
    init(origin: String? = nil, destination: String? = nil) {
        self.origin = origin
        self.destination = destination
        self.departureDateTime = nil
        self.arrivalDateTime = nil
        self.jetServiceType = nil
    }
}
