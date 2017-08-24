//
//  AppData.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import GooglePlaces

class AppData {
    
    class func setup() {
        
        if FeatureFlag.googlePlaces.isFeatureEnabled() {
            self.setupGooglePlaces()
        }
    }
    
    private class func setupGooglePlaces() {
        
        // :TODO: replace the API key with a prod version
        // AIzaSyBw3mFPyTCgpGF0DWbzE-Nga0kpkYp4qGU is the quota-limited dev/testing account API key from Lava Monster Labs, LLC google cloud account, and will not allow more than 25000 queries per day. Replace it with a paid prod API for release
        GMSPlacesClient.provideAPIKey("AIzaSyBw3mFPyTCgpGF0DWbzE-Nga0kpkYp4qGU")
    }

    class func onLogout() {
        
    }
}
