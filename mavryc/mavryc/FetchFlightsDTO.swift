//
//  FetchFlightsDTO.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

struct FetchFlightsDTO {
    
    let origin: String?
    let destination: String?
    
    init(origin: String? = nil, destination: String? = nil) {
        self.origin = origin
        self.destination = destination
    }
}
