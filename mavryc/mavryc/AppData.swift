//
//  AppData.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

class AppData {
    
    class func setup() {
        RealmConfiguration.setDefaultConfigurationEncrypted()
    }

    class func onLogout() {
        
    }
}
