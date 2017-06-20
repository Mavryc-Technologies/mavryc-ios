//
//  ConfirmDetailsScreenVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ConfirmDetailsScreenVC: UIViewController {

    @IBOutlet weak var bgView: UIImageView! {
        didSet {
            //bgView.image = AppState.tempBGImageForTransitionAnimationHack
        }
    }
    
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
    
    var nextButtonBottomSpaceOriginal: CGFloat = 20.0
    var nextButtonBottomSpaceRetracted: CGFloat = -80.0
    @IBOutlet weak var nextButtonBottomVerticalSpaceConstraint: NSLayoutConstraint! {
        didSet {
            self.nextButtonBottomSpaceOriginal = nextButtonBottomVerticalSpaceConstraint.constant
        }
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .confirmDetails)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ScreenNavigator.sharedInstance.currentPanelScreen = .confirmDetails
        
        self.nextButtonBottomVerticalSpaceConstraint.constant = self.nextButtonBottomSpaceOriginal
        self.NextButton.alpha = 1.0
        self.view.layoutIfNeeded()
        self.view.layoutSubviews()
        self.updateViewConstraints()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.NextButton.alpha = 0.0
        self.nextButtonBottomVerticalSpaceConstraint.constant = self.nextButtonBottomSpaceRetracted
        self.view.layoutIfNeeded()
    }
    
    @IBAction func bookButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
}

extension ConfirmDetailsScreenVC: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {
        
    }
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}
