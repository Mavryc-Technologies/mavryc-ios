//
//  ScreenCompletable.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

@objc protocol ScreenCompletable {
    func screenProgressDidUpdate(screen: UIViewController, isValidComplete: Bool)
}
