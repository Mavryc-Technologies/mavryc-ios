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
    
    /// feature flag query
    func isFeatureEnabled() -> Bool {
        
        switch self {
        case .joystickTrackedMapInteraction:
            // TODO: implement some mechanism for storage and retrieval, probably UserDefaults or config file or both
            // since we'd like to set this dynamically from either a web service, and/or the dev settings menu for runtime setting
            return false
            
        case .googlePlaces:
            // TODO: implement added mechanism here for dynamic setting/getting of this
            return true
            
        default:
            return true
        }
    }
}
