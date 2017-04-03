//
//  AppState.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class AppState {
    
    private enum StoreLookup: String {
        case onboardingWasSeen = "onboardingWasSeen"
//        case authenticationToken = "authenticationToken"
//        case deviceId = "deviceId"
        
        var key: String {
            get {
                return self.rawValue
            }
        }
    }
    
    /// Indicates whether onboarding module has been seen by user
    class var onboardingWasSeen: Bool {
        get {
            return UserDefaults.standard.bool(forKey: AppState.StoreLookup.onboardingWasSeen.key)
        }
        set (wasSeen) {
            UserDefaults.standard.set(wasSeen, forKey: AppState.StoreLookup.onboardingWasSeen.key)
        }
    }
    
}
