//
//  AppState.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AppState {
    
    enum StateLookup {
        
        case onboardingWasSeen(flag: Bool?)
        
        case googlePlaces(flag: Bool?)

        //case authenticationToken(token: String)

        //case deviceId(id: String)
        
        private func key() -> String {
            switch self {
            case .onboardingWasSeen(_):
                return "onboardingWasSeen"
            case .googlePlaces(_):
                return "googlePlaces"
            }
        }
        
        public func save() {

            switch self {
            case .onboardingWasSeen(let flag):
                if let flag = flag {
                    self.saveBoolString(flagBool: flag, key: self.key())
                }
            case .googlePlaces(let flag):
                if let flag = flag {
                    self.saveBoolString(flagBool: flag, key: self.key())
                }
            }
        }
        
        public func fetch() -> Any? {
            
            switch self {
            case .onboardingWasSeen(_):
                return self.boolFromBoolString(forKey: self.key())
                
            case .googlePlaces(_):
                return self.boolFromBoolString(forKey: self.key())
            }
        }
        
        private func saveBoolString(flagBool: Bool, key: String) {
            let boolStr = flagBool ? "true" : "false"
            UserDefaults.standard.set(boolStr, forKey: key)
        }
        
        private func boolFromBoolString(forKey: String) -> Bool? {
            // return true, false, or nil
            if let flag = UserDefaults.standard.string(forKey: forKey) {
                return self.bool(fromBoolString: flag)
            }
            return nil
        }
        
        private func bool(fromBoolString: String) -> Bool {
            if fromBoolString == "true" { return true } else { return false }
        }
    }
}
