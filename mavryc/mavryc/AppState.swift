//
//  AppState.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AppState {
    
    enum StateLookup: String {
        case onboardingWasSeen = "onboardingWasSeen"
        case googlePlaces = "googlePlaces"
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
            return UserDefaults.standard.bool(forKey: AppState.StateLookup.onboardingWasSeen.key)
        }
        set (wasSeen) {
            UserDefaults.standard.set(wasSeen, forKey: AppState.StateLookup.onboardingWasSeen.key)
        }
    }
    
    //class func save(state: StateLookup, optionalBool: Bool?, optionalString: String?)
    
    static var tempBGImageForTransitionAnimationHack: UIImage?
}
