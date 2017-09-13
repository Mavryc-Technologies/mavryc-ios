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
    
    @IBOutlet weak var outboundDepartCodeLabel: UILabel!
    @IBOutlet weak var outboundDepartCityLabel: UILabel!
    @IBOutlet weak var outboundDepartDateLabel: UILabel!
    @IBOutlet weak var outboundDepartTimePaxLabel: UILabel!
    
    @IBOutlet weak var outboundArrivalCodeLabel: UILabel!
    @IBOutlet weak var outboundArrivalCityLabel: UILabel!
    @IBOutlet weak var outboundArrivalDateLabel: UILabel!
    @IBOutlet weak var outboundArrivalTimePaxLabel: UILabel!
    
    @IBOutlet weak var returnDepartCodeLabel: UILabel!
    @IBOutlet weak var returnDepartCityLabel: UILabel!
    @IBOutlet weak var returnDepartDateLabel: UILabel!
    @IBOutlet weak var returnDepartTimePaxLabel: UILabel!
    
    @IBOutlet weak var returnArrivalCodeLabel: UILabel!
    @IBOutlet weak var returnArrivalCityLabel: UILabel!
    @IBOutlet weak var returnArrivalDateLabel: UILabel!
    @IBOutlet weak var returnArrivalTimePaxLabel: UILabel!
    
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
        
        self.updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .confirmDetails

        showReturnTripIfNeeded()
        showSplitFareButtonIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.updateUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func updateUI() {
        if let viewModel = ConfirmDetailsVeiwModelProvider.shared.confirmDetailsViewModel {
            self.aircraftServiceSelectedTitle.text = viewModel.jetserviceTypeString.lowercased().capitalizingFirstLetter()  + " Jet"
            self.totalAmountLabel.text = viewModel.tripTotalCost
            
            self.outboundDepartCityLabel.text = viewModel.city(of: .outboundDeparture)
            self.outboundArrivalCityLabel.text = viewModel.city(of: .outboundArrival)
            self.returnDepartCityLabel.text = viewModel.city(of: .returnDeparture)
            self.returnArrivalCityLabel.text = viewModel.city(of: .returnArrival)
            
            self.outboundDepartCodeLabel.text = viewModel.airportCode(flightSegment: .outboundDeparture)
            self.outboundArrivalCodeLabel.text = viewModel.airportCode(flightSegment: .outboundArrival)
            self.returnDepartCodeLabel.text = viewModel.airportCode(flightSegment: .returnDeparture)
            self.returnArrivalCodeLabel.text = viewModel.airportCode(flightSegment: .returnArrival)
        }
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
            self.presentLogin(animated: true)
        } else {
            
            // Removed to instead present Billing screen
            // self.presentApplePay()
            
            self.presentBillingScreen()
        }
    }
    
    func presentBillingScreen() {
        let storyboard = UIStoryboard.init(name: "Billing", bundle: Bundle.main)
        guard let billingVC = storyboard.instantiateInitialViewController() as? BillingViewController else {return}
        billingVC.delegate = self
        self.present(billingVC, animated: true, completion: nil)
    }
    
    func presentApplePay() {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - present/dismiss login support
    func presentLogin(animated: Bool) {
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            LoginManager.shared.presentLoginScreen(sender: visibleViewCtrl, delegate: self)
        }
    }

}

extension ConfirmDetailsScreenVC: BillingDelegate {
    
    func closeWasTapped() {
        // will handle closing from the billing screen itself.. this can probably be removed
    }
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
