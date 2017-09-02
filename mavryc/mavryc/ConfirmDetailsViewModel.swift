//
//  ConfirmDetailsViewModel.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/31/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class ConfirmDetailsVeiwModelProvider {
    
    static let shared = ConfirmDetailsVeiwModelProvider()
    var confirmDetailsViewModel: ConfirmDetailsViewModel?
}

struct ConfirmDetailsViewModel {
    
    let jetserviceTypeString: String
    let tripTotalCost: String
    
    func trip() -> Trip? {
        return TripCoordinator.sharedInstance.currentTripInPlanning
    }
}
