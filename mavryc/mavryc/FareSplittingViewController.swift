//
//  FareSplittingViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/13/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class FareSplittingViewController: UIViewController {

    // MARK: - Properties

    var fareSplitterControls: [FareSplitter] = []
    
    var extendedApplePayBottomVerticalSpaceValue: CGFloat = 0
    var retractedApplePayBottomVerticalSpaceValue: CGFloat = 0
    @IBOutlet weak var applePayBottomVerticalSpace: NSLayoutConstraint! {
        didSet {
            self.retractedApplePayBottomVerticalSpaceValue = applePayBottomVerticalSpace.constant
        }
    }
    
    @IBOutlet weak var screenTitle: UILabel! {
        didSet {
            screenTitle.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var fareSplitterControlsStackView: UIStackView! {
        didSet {
            fareSplitterControlsStackView.translatesAutoresizingMaskIntoConstraints = false
            fareSplitterControlsStackView.spacing = 20
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .splitFare)
    
    }
    
    // MARK: - Control Actions
    
    @IBAction func bookButtonAction(_ sender: Any) {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.extendedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func applePayCancelTapAction(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25) {
            self.applePayBottomVerticalSpace.constant = self.retractedApplePayBottomVerticalSpaceValue
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func fareSplitAddButtonAction(_ sender: UITapGestureRecognizer) {
        print("adding a fare splitter control")
        
        let control = FareSplitter(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        control.heightAnchor.constraint(equalToConstant: 150).isActive = true
        control.widthAnchor.constraint(equalToConstant: 300).isActive = true
        fareSplitterControlsStackView.addArrangedSubview(control)
        self.fareSplitterControls.append(control)
        control.delegate = self
    }
}

extension FareSplittingViewController: ScreenNavigable {
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {}
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}

extension FareSplittingViewController: FareSplitterDelegate {
    func fareSplitter(fareSplitter: FareSplitter, closeButtonWasTapped:  Bool) {
        print("close button was tapped on \(fareSplitter)")
        self.fareSplitterControlsStackView.removeArrangedSubview(fareSplitter)
        fareSplitter.removeFromSuperview()
    }
    
    func fareSplitter(fareSplitter: FareSplitter, didUpdateBarsToVale: Int) {
        print("bars updated to \(didUpdateBarsToVale) by \(fareSplitter)")
    }
    
}
