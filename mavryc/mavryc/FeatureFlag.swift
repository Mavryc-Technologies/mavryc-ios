//
//  FeatureFlag.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/17/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

enum FeatureFlag {

    case joystickTrackedMapInteraction
    case mapboxAirportAnnotationClustering
    case googlePlaces
    case militaryTime
    
    /// feature flag query
    func isFeatureEnabled() -> Bool {
        
        switch self {
        case .joystickTrackedMapInteraction:
            // TODO: utilize AppStore like .googlePlaces feature flag below
            return false
            
        case .googlePlaces:
            if let isEnabled = AppState.StateLookup.googlePlaces(flag: nil).fetch() as? Bool {
                return isEnabled
            } else {
                return true // default if not set elsewhere
            }
            
        case .militaryTime:
            return false
            
        default:
            return true
        }
    }
}
