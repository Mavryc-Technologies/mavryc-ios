//
//  UIStoryboard+Storyboards.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    /// The place where we list all the storyboard names in our app
    ///
    /// - Main:       Main Contest Screen(s)
    /// - Onboarding: Onboarding screens/videos
    /// - Profile:    User Profile splash and Profile Signup and/or Details
    /// - Settings:   Account Settings, Legal, Contact Us
    enum Storyboard: String {
        case Main
        case Onboarding
//        case Profile
//        case Settings
//        case NotLoggedInCustomScreen(s)...
//        case Login
    }
    
    /* Usage:
     This extension and related protocol and extensions (StoryboardIdentifiable.swift, UIViewController+StoryboardIdentifier.swift)
     are designed to eliminate string literals and all related unsafety + provides less pain in calling storyboards from our viewControllers.
     Here is a call site example from any given viewController:
     
     let mainStoryboard = Storyboard(storyboard: .Main)
     let mainVC = mainStoryboard.instantiateViewController(mainStoryboard)
     presentViewController(viewController, animated: true, completion: nil)
     
     Setup:
     Update the enum Storyboard above to contain any storyboards in your project
     NOTE! Always remember to set an initial view controller for each storyboard. It will save you much troubleshooting.
     
     Author: Todd Hopkinson
     Ref: based on https://github.com/andyyhope/Blog_UIStoryboardSafety
     */
    
    /// Convenience Initializers
    convenience init(storyboard: Storyboard, bundle: Bundle? = nil) {
        self.init(name: storyboard.rawValue, bundle: bundle)
    }
    
    /// Class Functions
    class func storyboard(storyboard: Storyboard, bundle: Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: bundle)
    }
    
    func instantiateViewController<T: UIViewController>() -> T where T: StoryboardIdentifiable {
        guard let viewController = self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T else {
            fatalError("Couldn't instantiate view controller with identifier \(T.storyboardIdentifier) ")
        }
        
        return viewController
    }
}
