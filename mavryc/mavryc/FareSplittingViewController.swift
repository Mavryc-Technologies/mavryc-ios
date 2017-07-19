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
    
    @IBOutlet weak var primaryFareSplitter: FareSplitter! {
        didSet {
            primaryFareSplitter.delegate = self
        }
    }
    
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
    
    @IBOutlet weak var fareSplitterAddButton: UIImageView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .splitFare)
        if let seats = self.tripSeatsTotal() {
            self.primaryFareSplitter.updateControlQuietlyWith(seatCount: seats)
        }
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
        
        if self.fareSplitterControls.count > 0 {
            self.fareSplitterAddButton.isHidden = true
        }
        
        if let seats = self.tripSeatsTotal() {
            self.fareSplitterControls[0].updateControlQuietlyWith(seatCount: 1)
            self.primaryFareSplitter.updateControlQuietlyWith(seatCount: seats - 1)
        }
    }
    
    // MARK: - API & support
    func tripSeatsTotal() -> Int? {
        let total = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].pax
        return total
    }
    
    func tripPriceTotal() -> String? {
        let total = TripCoordinator.sharedInstance.currentTripInPlanning?.totalPrice()
        return total
    }
    
    func recalculateSeats(dirtyControl: FareSplitter, updateSplitterControls: Bool) {
        // 1. recalc seats for all controls

        // 2. recalc prices for all controls
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
    
    func priceFor(seatCount: Int) -> String {
        if let totalSeats = self.tripSeatsTotal(), let totalPrice = self.tripPriceTotal() {
            // TODO: implement NSDecimal price stored in Trip rather than convenience hard coded string here
            let price = 14775
            let perSeatCost = price / totalSeats
            let priceAtSeatCount = seatCount * perSeatCost
            
            let priceToFormat = priceAtSeatCount as NSNumber
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            let output = formatter.string(from: priceToFormat) // "$123.44"
            
            return output!
        }
        
        return "$1.00"
    }
    
    func fareSplitter(fareSplitter: FareSplitter, closeButtonWasTapped:  Bool) {
        print("close button was tapped on \(fareSplitter)")
        self.fareSplitterControlsStackView.removeArrangedSubview(fareSplitter)
        fareSplitter.removeFromSuperview()
        fareSplitterControls.removeLast()
        
        if fareSplitterControls.count > 0 {
            fareSplitterAddButton.isHidden = true
        } else {
            fareSplitterAddButton.isHidden = false
        }
        
        // redistribute to primary control
        if let seats = self.tripSeatsTotal() {
            self.primaryFareSplitter.updateControlQuietlyWith(seatCount: seats)
        }
    }
    
    func fareSplitter(fareSplitter: FareSplitter, didUpdateBarsToVale: Int) {
        print("bars updated to \(didUpdateBarsToVale) by \(fareSplitter)")
        
        // determine remainder seats left for other guy, quietly update him
        guard let totalSeats = self.tripSeatsTotal() else { return }
        let remainder = totalSeats - didUpdateBarsToVale
        
        var control: FareSplitter? = nil
        
        if fareSplitter.isPrimaryUserControl {
            // update the secondary control
            if self.fareSplitterControls.count > 0 {
                control = self.fareSplitterControls[0]
            } else { return }
        } else {
            // update primary control
            control = self.primaryFareSplitter
        }
        
        if let control = control {
            print("All systems check. Greenlight on the quiet update to proceed. Go....3.2.1...")
            control.updateControlQuietlyWith(seatCount: remainder)
        }
    }
    
    func maximumSeatsAvailable() -> Int {
        guard let seats = self.tripSeatsTotal() else { return 1 }
        return seats
    }
}


