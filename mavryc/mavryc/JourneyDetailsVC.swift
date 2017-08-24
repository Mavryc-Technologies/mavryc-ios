//
//  JourneyDetailsVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

class JourneyDetailsVC: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var nextButton: StyledButton! {
        didSet {
            nextButton.isEnabled = true
        }
    }

    var offscreenRight: CGFloat = 1000.0
    var offscreenLeft: CGFloat = -1000.0
    var onscreenX: CGFloat = 20.0
    
    var isMainViewControllerOffscreen = false
    
    weak var outboundVC: OutboundReturnViewController? = nil
    
    @IBOutlet weak var outboundTripXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var returnTripXConstraint: NSLayoutConstraint! {
        didSet {
            returnTripXConstraint.constant = self.offscreenRight
        }
    }
    
    weak var returnVC: OutboundReturnViewController? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .journey)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelWillOpen),
                                               name: Notification.Name.PanelScreen.WillOpen,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelDidOpen),
                                               name: Notification.Name.PanelScreen.DidOpen,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelWillClose),
                                               name: Notification.Name.PanelScreen.WillClose,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationDidUpdate), name: Notification.Name.Location.UserLocationDidUpdate, object: nil)
        
        self.setupSwipeGesture()
        
        // this will center appropriately each subscreen setting their constraint.constant to onscreenX
        self.onscreenX = ((self.view.frame.size.width - 300) / 2)
        outboundTripXConstraint.constant = onscreenX
        returnTripXConstraint.constant = offscreenRight
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addOrCloseWasTapped),
                                               name: Notification.Name.SubscreenEvents.OutboundReturnAddOrCloseButtonTap,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(flightNavSubScreenControlWasTapped),
                                               name: Notification.Name.SubscreenEvents.FlightNavigationSubscreenControlButtonWasTapped,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .journey
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isMainViewControllerOffscreen = false
        self.onscreenX = ((self.view.frame.size.width - 300) / 2)
        outboundTripXConstraint.constant = onscreenX
        returnTripXConstraint.constant = offscreenRight
        transitionToSubscreen(screen: 0)
        updateScreenNavigationForSubscreen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isMainViewControllerOffscreen = true
        self.updateScreenNavigationForSubscreen()
    }
    
    // MARK: - Outbound Return Subscreen Support
    
    @objc private func flightNavSubScreenControlWasTapped(notification: NSNotification) {
        let state = self.subscreenState()
        if state == .ignoreSubscreenStates {
            return
        }
        if state == .oneWayOnly {
            return
        }
        if state == .outboundVisible {
            self.transitionToSubscreen(screen: 1)
        }
        if state == .returnVisible {
            self.transitionToSubscreen(screen: 0)
        }
    }
    
    @objc private func addOrCloseWasTapped(notif: NSNotification) {
        
        if let userInfo = notif.userInfo as? [String: Int] {
            if let isOneWayOnlyFlag = userInfo[Notification.Name.SubscreenEvents.oneWayOnlyKey] {
                let isOneWay = isOneWayOnlyFlag == 1 ? true : false
                if isOneWay { // meaning no round trip exists
                    // set title to OUTBOUND JOURNEY (no chevron)
                    transitionToSubscreen(screen: 0)
                } else {
                    // set title to RETURN JOURNEY (LESS THAN CHEVRON)
                    // remove main title down/up chevron
                    transitionToSubscreen(screen: 1)
                }
            }
        }
        
        self.returnVC?.refreshUI()
        self.outboundVC?.refreshUI()
    }
    
    /// animate to subscreen
    /// param: screen -- 0 for Outbound, screen 1 for Return
    func transitionToSubscreen(screen: Int) {
        let isOneWay = screen == 0 ? true : false
        if isOneWay {
            UIView.animate(withDuration: 0.3, animations: { 
                if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
                    if trip.isOneWayOnly {
                        // set title to OUTBOUND JOURNEY (no chevron)
                    } else {
                        // set title to OUTBOUND JOURNEY (Greater than chevron)
                    }
                }
                self.outboundTripXConstraint.constant = self.onscreenX
                self.returnTripXConstraint.constant = self.offscreenRight
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                self.updateScreenNavigationForSubscreen()
            })
        } else {
            returnTripXConstraint.constant = self.offscreenRight
            UIView.animate(withDuration: 0.3, animations: { 
                self.returnTripXConstraint.constant = self.onscreenX
                self.outboundTripXConstraint.constant = self.offscreenLeft
                // set title to RETURN JOURNEY (less than chevron)
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                    self.updateScreenNavigationForSubscreen()
            })
        }
        
    }
    
    func updateScreenNavigationForSubscreen() {
        NotificationCenter.default.post(name: Notification.Name.SubscreenEvents.JourneySubscreenStateDidUpdate,
                                        object: self,
                                        userInfo:[Notification.Name.SubscreenEvents.journeySubscreenStateEnumKey: self.subscreenState().rawValue])
    }
    
    func subscreenState() -> Notification.Name.SubscreenEvents.JourneySubcreenState {

        if self.isMainViewControllerOffscreen {
            return .ignoreSubscreenStates
        }
        
        if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
            if !trip.isOneWayOnly {
                if self.returnTripXConstraint.constant == onscreenX {
                    return .returnVisible
                } else {
                    return .outboundVisible
                }
            }
        }

        return .oneWayOnly
    }
    
    
    // MARK: - swipe support
    
    func setupSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")

            if subscreenState() == .returnVisible {
                self.transitionToSubscreen(screen: 0)
                return
            }
            
            if subscreenState() == .oneWayOnly || subscreenState() == .ignoreSubscreenStates {
                ScreenNavigator.sharedInstance.navigateBackward()
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            
            if subscreenState() == .outboundVisible {
                self.transitionToSubscreen(screen: 1)
                return
            }
            
            if nextButton.isEnabled {
                if subscreenState() == .oneWayOnly || subscreenState() == .ignoreSubscreenStates {
                    self.performSegue(withIdentifier: "AircraftSelectionScreenSegue", sender: self)
                }
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.down {
            print("Swipe Down")
            if subscreenState() == .oneWayOnly || subscreenState() == .ignoreSubscreenStates {
                ScreenNavigator.sharedInstance.closePanel()
            }
        }
    }
    
    // MARK: - Notification Handlers
    
    @objc private func userLocationDidUpdate(notification: Notification) {

        if let location = notification.userInfo?["location"] as? CLLocation {
            print("\(location)")
            
            self.outboundVC?.updateTripRecord(departure: location, updateDepartureField: true)
        }
    }
    

    // MARK: - Panel Support
    
    @objc private func panelWillOpen() {
        print("panelWillOpen notification handler called")
    }
    
    @objc private func panelDidOpen() {
        print("panelDidOpen notification handler called")
        self.isMainViewControllerOffscreen = false
        
        if ScreenNavigator.destinationSearchButtonWasPressedState {
            self.outboundVC?.arrivalSearchTextField.becomeFirstResponder()
        }
        
        updateScreenNavigationForSubscreen()
    }
    
    @objc private func panelWillClose() {
        print("panelWillClose notification handler called")
        
        self.outboundVC?.deselectSearchControls()
        self.returnVC?.deselectSearchControls()
        self.isMainViewControllerOffscreen = true
        self.updateScreenNavigationForSubscreen()
    }
    
    // MARK: - Control Actions
    
    @IBAction func nextButtonAction(_ sender: Any) {
        print("next button pressed")
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OutboundVCSegue" {
            let vc = segue.destination as? OutboundReturnViewController
            self.outboundVC = vc
            vc?.screenCompletableDelegate = self
        } else if segue.identifier == "ReturnTripVCSegue" {
            let vc = segue.destination as? OutboundReturnViewController
            vc?.isOutboundController = false
            self.returnVC = vc
            vc?.screenCompletableDelegate = self
        }
    }
}


// MARK: - ScreenCompletable extension

extension JourneyDetailsVC: ScreenCompletable {
    func screenProgressDidUpdate(screen: UIViewController, isValidComplete: Bool) {
        self.nextButton.isHidden = !isValidComplete
    }
}

// MARK: - ScreenNavigable extension

extension JourneyDetailsVC: ScreenNavigable {
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {}
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}
