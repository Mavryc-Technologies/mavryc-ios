//
//  ConfirmDetailsScreenVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ConfirmDetailsScreenVC: UIViewController {

    @IBOutlet weak var bgView: UIImageView!
    
    @IBOutlet weak var NextButton: StyledButton!
    
    @IBOutlet weak var returnTripContainterView: UIView!
    
    @IBOutlet weak var splitFareButton: UIButton!
    
    // MARK: - placeholder ApplePay
    var extendedApplePayBottomVerticalSpaceValue: CGFloat = 0
    var retractedApplePayBottomVerticalSpaceValue: CGFloat = 0
    @IBOutlet weak var applePayBottomVerticalSpace: NSLayoutConstraint! {
        didSet {
            self.retractedApplePayBottomVerticalSpaceValue = applePayBottomVerticalSpace.constant
        }
    }
    
    /// dismiss apple pay standin
    @IBAction func applePayTap(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25) { 
            self.applePayBottomVerticalSpace.constant = self.retractedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var screenTitle: UILabel! {
        didSet {
            screenTitle.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var tripSectionTitle: UILabel! {
        didSet {
            tripSectionTitle.textColor = AppStyle.skylarBlueGrey
        }
    }
    
    @IBOutlet weak var aircraftServiceSelectedTitle: UILabel! {
        didSet {
            aircraftServiceSelectedTitle.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var totalAmountLabel: UILabel! {
        didSet {
            totalAmountLabel.textColor = AppStyle.skylarGold
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .confirmDetails)
        
        self.setupSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .confirmDetails

        showReturnTripIfNeeded()
        showSplitFareButtonIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupSwipeGesture() {
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            ScreenNavigator.sharedInstance.navigateBackward()
        }
    }
    
    func showSplitFareButtonIfNeeded() {
        
        if !FeatureFlag.splitFareOnConfirmScreen.isFeatureEnabled() {
            self.splitFareButton.isHidden = true
            return
        }
        
        if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
            guard let paxCount = trip.flights[0].pax else { return }
            if paxCount > 1 {
                self.splitFareButton.isHidden = false
                return
            }
        }
        
        self.splitFareButton.isHidden = true
    }
    
    func showReturnTripIfNeeded() {
        if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
            if !trip.isOneWayOnly {
                self.returnTripContainterView.isHidden = false
            } else {
                self.returnTripContainterView.isHidden = true
            }
        }
    }
    
    // MARK: - Control Actions
    
    @IBAction func bookButtonAction(_ sender: Any) {
        
        // if user isn't logged in, do that first, then return here and try again
        if !User.isUserLoggedIn() {
//            LoginManager.shared.presentLoginScreen(sender: self)
            self.presentLogin(animated: true)
        } else {
            UIView.animate(withDuration: 0.25) {
                self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - present/dismiss login support
    func presentLogin(animated: Bool) {
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            LoginManager.shared.presentLoginScreen(sender: visibleViewCtrl, delegate: self)
        }
    }
    
//    func dismissSlideOutMenu(animated: Bool) {
//        // make it go away
//        if let vc = self.slideoutMenuViewController, let _ = slideOutMenuPresentingViewController {
//            
//            var offScreenFrame = vc.view.frame
//            offScreenFrame.origin.x = (vc.view.frame.width * -1) - 1
//            
//            UIView.animate(withDuration: 0.3, animations: {
//                vc.view.frame = offScreenFrame
//                vc.view.layoutIfNeeded()
//                self.view.layoutIfNeeded()
//            }, completion: { (done) in
//                vc.view.removeFromSuperview()
//                self.slideoutMenuViewController = nil
//                UIApplication.shared.isStatusBarHidden = false
//            })
//        }
//    }
}

extension ConfirmDetailsScreenVC: ScreenNavigable {
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {}
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}

extension ConfirmDetailsScreenVC: LoginMulticastDelegate {
    
    func identifier() -> String {
        return self.description
    }
    
    func onLogin(success: Bool, manager: LoginManager, Login: LoginUser) {
        print("onLogin")
        
        if success {
            print("login success")
            manager.dismissLoginScreen()
        }
    }
    
    func onLogout(manager: LoginManager) {
        print("onLogout")
    }
}
