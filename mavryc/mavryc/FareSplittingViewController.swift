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

    @IBOutlet weak var myFareSplitter: FareSplitterCondensed! {
        didSet {
            myFareSplitter.delegate = self
        }
    }
    
    var fareSplitterControls: [FareSplitter] = []
    //var condensedFareSplitterControls: [FareSplitterCondensed] = []
    
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
    
    @IBOutlet weak var AddPaymentLabel: UILabel!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .splitFare)
        if let seats = self.tripSeatsTotal() {
            self.myFareSplitter.updateControlQuietlyWith(seatCount: seats)
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
        
        var isLastControlReadyForReduction: Bool = false
        if let last = fareSplitterControlsStackView.arrangedSubviews.last {
            if let uncondensed = fareSplitterControls.last {
                if last == uncondensed {
                    isLastControlReadyForReduction = true
                }
            }
        }
        
        if isLastControlReadyForReduction {
            // turn the current last to a condensed control before adding this new guy
            let condensedControl = FareSplitterCondensed(frame: CGRect(x: 0, y: 0, width: 300, height: 57))
            condensedControl.heightAnchor.constraint(equalToConstant: 57).isActive = true
            condensedControl.widthAnchor.constraint(equalToConstant: 300).isActive = true
            if let lastControl = self.fareSplitterControls.last {
                condensedControl.delegate = self
                condensedControl.uncondensedCounterpart = lastControl
                lastControl.isHidden = true
                condensedControl.priceLabel.text = lastControl.priceLabel.text
                condensedControl.seatsLabel.text = lastControl.seatsLabel.text
                fareSplitterControlsStackView.addArrangedSubview(condensedControl)
                fareSplitterControlsStackView.removeArrangedSubview(lastControl)
                if let tag = fareSplitterControlsStackView.arrangedSubviews.index(of: condensedControl) {
                    condensedControl.tag = tag
                    lastControl.tag = tag
                }
            }
        }
        
        let control = FareSplitter(frame: CGRect(x: 0, y: 0, width: 300, height: 150))
        control.heightAnchor.constraint(equalToConstant: 150).isActive = true
        control.widthAnchor.constraint(equalToConstant: 300).isActive = true
        fareSplitterControlsStackView.addArrangedSubview(control)
        self.fareSplitterControls.append(control)
        control.delegate = self
        control.updateControlQuietlyWith(seatCount: 1)
        if let seats = Int(myFareSplitter.seatsLabel.text!) {
            self.myFareSplitter.updateControlQuietlyWith(seatCount: seats - 1)
        }
        
        if self.fareSplitterControls.count > 2 {
            self.fareSplitterAddButton.isHidden = true
            self.AddPaymentLabel.isHidden = true
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
    
    func totalBarsAllowedForFareSplitter(fareSplitter: FareSplitter) -> Int {
        return self.tripSeatsTotal()!
    }
    
    func priceFor(seatCount: Int) -> String {
        if let totalSeats = self.tripSeatsTotal() {
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
    
    func fareSplitter(fareSplitter: FareSplitter,
                      counterpart: UIView?,
                      closeButtonWasTapped:  Bool) {
        
        print("close button was tapped on \(fareSplitter)")
        let reclaimedSeats = Int(fareSplitter.seatsLabel.text!)!
        if let counterpart = counterpart {
            self.fareSplitterControlsStackView.removeArrangedSubview(counterpart)
            counterpart.removeFromSuperview()
        } else {
            self.fareSplitterControlsStackView.removeArrangedSubview(fareSplitter)
            fareSplitter.removeFromSuperview()
        }
        
        if let position = fareSplitterControls.index(of: fareSplitter) {
            fareSplitterControls.remove(at: position)
        }
        
        if fareSplitterControls.count > 0 {
            // inflate a remaining condensed view
            if let inflatable = fareSplitterControls.last {
                if let visibleControl = self.fareSplitterControlsStackView.arrangedSubviews.last {
                    if inflatable.tag == visibleControl.tag {
                        // replace visible with counterpart big boy
                        fareSplitterControlsStackView.removeArrangedSubview(visibleControl)
                        visibleControl.removeFromSuperview()

                        inflatable.heightAnchor.constraint(equalToConstant: 150).isActive = true
                        inflatable.widthAnchor.constraint(equalToConstant: 300).isActive = true
                        fareSplitterControlsStackView.addArrangedSubview(inflatable)
                        inflatable.isHidden = false
                    }
                }
            }
        }
        
        if fareSplitterControls.count > 2 {
            fareSplitterAddButton.isHidden = true
            self.AddPaymentLabel.isHidden = true
        } else {
            fareSplitterAddButton.isHidden = false
            self.AddPaymentLabel.isHidden = false
        }
        
        // redistribute to primary control
        let currentSeats = Int(myFareSplitter.seatsLabel.text!)! + reclaimedSeats
        self.myFareSplitter.updateControlQuietlyWith(seatCount: currentSeats)
    }
    
    func fareSplitter(fareSplitter: FareSplitter, didUpdateBarsToVale: Int) {
        print("bars updated to \(didUpdateBarsToVale) by \(fareSplitter)")
        
        var currentCumulativeSeats: Int = 0
        currentCumulativeSeats = currentCumulativeSeats + Int(myFareSplitter.seatsLabel.text!)!
        for splitter in fareSplitterControls {
            currentCumulativeSeats = currentCumulativeSeats + Int(splitter.seatsLabel.text!)!
        }
        var delta: Int = 0
        
        if fareSplitter.isPrimaryUserControl {
            // if My Payment
            // delta goes to or from Last Control
            delta = (self.tripSeatsTotal()! - currentCumulativeSeats)
            if let control = self.fareSplitterControls.last {
                control.updateControlQuietlyWith(seatCount: delta)
            }
        } else {
            // if non my payment
            // delta goes to or from My Payment
            delta = (self.tripSeatsTotal()! - currentCumulativeSeats)
            let myFareSeats = Int(myFareSplitter.seatsLabel.text!)! + delta
            myFareSplitter.updateControlQuietlyWith(seatCount: myFareSeats)
        }
    }
    
    func maximumSeatsAvailable() -> Int {
        guard let seats = self.tripSeatsTotal() else { return 1 }
        return seats
    }
}


