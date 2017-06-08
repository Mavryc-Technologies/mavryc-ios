//
//  ConfirmDetailsScreenVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ConfirmDetailsScreenVC: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func bookButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
}
