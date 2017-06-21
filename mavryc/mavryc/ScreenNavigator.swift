//
//  ScreenNavigator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/15/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

protocol ScreenNavigable {
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool)
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool?
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator)
}

enum Screen {
    case retractedHome
    case journey
    case aircraftSelection
    case confirmDetails
    
    func nextSceenOnBackTap(isOpen: Bool) -> Screen {
        if isOpen {
            switch self {
            case .journey:
                return .retractedHome
            case .aircraftSelection:
                return .journey
            case .confirmDetails:
                return .aircraftSelection
            default:
                return self
            }
        }
        return self
    }
    
    func panelTitle() -> String {
        switch self {
        case .retractedHome:
            return "JOURNEY DETAILS"
        case .journey:
            return "JOURNEY DETAILS"
        case .aircraftSelection:
            return ""
        case .confirmDetails:
            return ""
        }
    }
    
    func shouldShowChevron() -> Bool {
        switch self {
        case .journey:
            return true
        case .aircraftSelection:
            return false
        case .confirmDetails:
            return false
        case .retractedHome:
            return true
        }
    }
}

class ScreenNavigator {
    
    public static let sharedInstance = ScreenNavigator()
    
    private init() {
        self.currentPanelScreen = Screen.retractedHome
        setupNavigationControl()
    }
    
    private var panelController: ScreenNavigable?
    
    private var registeredScreens: [Screen:ScreenNavigable] = [:]
    
    /// Set the current screen here (to be used anytime a screen becomes active)
    public var currentPanelScreen: Screen {
        didSet {
            self.refreshCurrentScreen()
        }
    }
    
    /// Registers a screen and associates its given type
    public func registerScreen(screen: ScreenNavigable, asScreen: Screen) {
        self.registeredScreens[asScreen] = screen
    }
    
    public func registerPanelController(panelController: ScreenNavigable) {
        self.panelController = panelController
    }
    
    public func refreshCurrentScreen() {
        self.panelController?.screenNavigatorRefreshCurrentScreen(self)
    }
    
    // MARK: - Navigation Control
    private func setupNavigationControl() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didTapBackNavButton),
                                               name: Notification.Name.PanelScreen.DidTapBackNav,
                                               object: nil)
    }
    
    @objc private func didTapBackNavButton() {
        print("didTapBackNavButton notification handler called")
       
        let nav = navController()
        
        guard let isOpen = panelController?.screenNavigatorIsScreenVisible(self) else { return }
        let nextScreen = currentPanelScreen.nextSceenOnBackTap(isOpen: isOpen)
        
        switch nextScreen {
        case .aircraftSelection:
            nav?.popViewController(animated: true)
            break
        case .journey:
            nav?.popViewController(animated: true)
            break
        case .retractedHome:
            panelController?.screenNavigator(self, backButtonWasPressed: true)
        default:
            break
        }
    }
    
    private func navController() -> UINavigationController? {
        if let rootVC = self.registeredScreens[.journey] as? UIViewController {
            return rootVC.navigationController
        }
        return nil
    }
}
