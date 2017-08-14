//
//  Notification+Menu.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/10/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    /// Used as a namespace for all `Panel` related notifications.
    public struct SlideoutMenu {
        
        public static let CloseWasTapped = Notification.Name(rawValue: "com.mavryk.notification.name.SlideoutMenu.CloseWasTapped")
        

        public static let MenuSubScreenCloseWasTapped = Notification.Name(rawValue: "com.mavryk.notification.name.SlideoutMenu.MenuSubScreenCloseWasTapped")
    }
}
