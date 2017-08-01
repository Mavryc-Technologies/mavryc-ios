//
//  FareSplitterCondensed.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

@IBDesignable class FareSplitterCondensed: UIView {
    
    // MARK: - API
    
    /// Updates the control visuals without sending callbacks or delegate calls/notifications
    public func updateControlQuietlyWith(seatCount: Int) {
        guard let price = delegate?.priceFor(seatCount: seatCount) else { return }
        self.priceLabel.text = price
        self.seatsLabel.text = String(seatCount)
    }
    
    // MARK: - Properties
    
    var delegate: FareSplitterDelegate? {
        didSet {
            //self.setupBars()
        }
    }
    
    weak var uncondensedCounterpart: FareSplitter?
    
    @IBOutlet weak var backgroundShapeView: UIView! {
        didSet {
            backgroundShapeView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet weak var closeButton: UIImageView!
    
    @IBInspectable var isPrimaryUserControl: Bool = false {
        didSet {
            if isPrimaryUserControl {
                closeButton.isHidden = true
                contactInfoLabel.text = "My Payment"
                self.backgroundShapeView.layer.borderWidth = 1.0
                self.backgroundShapeView.layer.borderColor = AppStyle.skylarGrey.cgColor
            } else {
                closeButton.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var seatsLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var contactInfoLabel: UILabel!
    
    
    // MARK: - Initialization
    @IBOutlet var view: UIView!
    var nibName: String = "FareSplitterCondensed"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func loadViewFromNib() -> UIView {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    func setup() {
        view = loadViewFromNib()
        view.translatesAutoresizingMaskIntoConstraints = true // NOTE: lesson learned: hours saved if you'll remember -- without this set to true, you'll need to programaticaly provide constraints
        view.frame = self.bounds
        addSubview(view)
        
        view.backgroundColor = UIColor.clear
    }
    
    // MARK: - Control Actions
    
    @IBAction func closeButtonTapAction(_ sender: UITapGestureRecognizer) {
        if let counterpart = self.uncondensedCounterpart {
            delegate?.fareSplitter(fareSplitter: counterpart, counterpart: self, closeButtonWasTapped: true)
        }
    }
    
}
