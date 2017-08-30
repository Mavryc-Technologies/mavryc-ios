//
//  AircraftServicesViewModel.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/29/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class AircraftServiceProvider {
    static let shared = AircraftServiceProvider()
    
    var viewModel: AircraftServicesViewModel?
}

struct AircraftServicesViewModel {
    let flights: [Flight]
    
    init(flights: [Flight]) {
        self.flights = flights
    }
}
