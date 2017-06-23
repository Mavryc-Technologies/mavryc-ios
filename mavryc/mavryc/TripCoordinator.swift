//
//  TripCoordinator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class TripCoordinator: NSObject {
    
    static let sharedInstance = TripCoordinator()
    
    var currentTripInPlanning: Trip?
}
