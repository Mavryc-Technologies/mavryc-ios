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
    
    
    
    @IBAction func bookButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
}

extension ConfirmDetailsScreenVC: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
    
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {
    }
}
