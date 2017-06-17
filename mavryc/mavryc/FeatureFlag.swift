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
    
    /// feature flag query
    static func isFeatureEnabled(_ feature: FeatureFlag) -> Bool {
        
        switch feature {
        case .joystickTrackedMapInteraction:
            // TODO: implement some mechanism for storage and retrieval, probably UserDefaults or config file or both
            // since we'd like to set this dynamically from either a web service, and/or the dev settings menu for runtime setting
            return false
            
        default:
            return true
        }
    }
}
