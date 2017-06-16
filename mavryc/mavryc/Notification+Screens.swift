//
//  Notification+Screens.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/15/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    /// Used as a namespace for all `Panel` related notifications.
    public struct PanelScreen {
        
        /// Posted when Panel is about to open.
        public static let WillOpen = Notification.Name(rawValue: "com.mavryk.notification.name.panel.willOpen")
        
        /// Posted when Panel is opened.
        public static let DidOpen = Notification.Name(rawValue: "com.mavryk.notification.name.panel.didOpen")
        
        /// Posted when Panel is about to open.
        public static let WillClose = Notification.Name(rawValue: "com.mavryk.notification.name.panel.willClose")
        
        /// Posted when Panel is closed.
        public static let DidClose = Notification.Name(rawValue: "com.mavryk.notification.name.panel.didClose")
        
        public static let DidTapBackNav = Notification.Name(rawValue: "com.mavryk.notification.name.panel.didTapBackNav")
    }
}
