//
//  Notification+Location.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    /// Used as a namespace for all `Panel` related notifications.
    public struct Location {
        
        /// Posted when user location did update
        public static let UserLocationDidUpdate = Notification.Name(rawValue: "com.mavryk.notification.name.location.userLocationDidUpdate")
    }
}
