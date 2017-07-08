//
//  AppCoordinator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

final class AppCoordinator {
    
    public static var shared: AppCoordinator?
    private var window: UIWindow!
    private var loadingWindow: UIWindow?
    
    /// Initialization expressly intended only from AppDelegate call-site
    init(window: UIWindow) {
        if AppCoordinator.shared != nil { return }
        AppCoordinator.shared = self
        self.window = window
    }
    
    public func start() {
        
        SafeLog.print("👉 NOTE: use SafeLog.print() instead of print() to keep logs safe in that we can turn off from compiler for release builds. We don't want logs printing in release mode. 👈\n")
        
        if let onboardingWasSeen = AppState.StateLookup.onboardingWasSeen(flag: nil).fetch() as? Bool {

            if onboardingWasSeen {
                print("show main")
                showMain()
                return
            }
        }
        
        print("show onboarding")
        showOnboarding()
    }
    
    private func showOnboarding() {
        SafeLog.print("showing onboarding...")
        
        let storyboard = UIStoryboard(storyboard: .Onboarding)
        guard let vc = storyboard.instantiateInitialViewController() else {
            print("fail! - unable to instantiate(and unwrap) view controller from storyboard at showOnboarding()")
            return
        }
        self.window.rootViewController = vc
    }
    
    private func showMain() {
        SafeLog.print("showing main...")
        
        let storyboard = UIStoryboard(storyboard: .Main)
        guard let vc = storyboard.instantiateInitialViewController() else {
            print("fail! - unable to instantiate(and unwrap) view controller from storyboard at showMain()")
            return
        }
        self.window.rootViewController = vc
    }
    
    public static func dismissFeature(viewController: UIViewController) {
        if viewController is OnboardingViewController {
            AppState.StateLookup.onboardingWasSeen(flag: true).save()
            shared?.showMain()
        }
    }
}
