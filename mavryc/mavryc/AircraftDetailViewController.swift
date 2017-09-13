//
//  AircraftDetailViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/28/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

@objc protocol AircraftDetailProtocol {
    func selectedAircraftIndex() -> Int
    func aircraftWasSelected(atIndex: Int)
    func closeButtonWasTapped()
}

class AircraftDetailViewController: UIViewController {

    // MARK: - Properties
    public weak var delegate: AircraftDetailProtocol? = nil
    
    //weak var cell: AircraftSelectCell? = nil
    public var titleData: String = ""
    public var costData: String = ""
    public var subtitleData: String = ""
    
    // will be used for internal support
    private var unattributedTitle: String?
    
    // MARK: - Outlets
    @IBOutlet weak var primaryLabel: UILabel!
    
    @IBOutlet weak var secondaryLabel: UILabel!
    
    @IBOutlet weak var closeButtonImageView: UIImageView!
    
    @IBOutlet weak var bodyTextView: UITextView!
    
    @IBOutlet weak var aircraftIconImageView: UIImageView!
    
    @IBOutlet weak var clearButtonView: UIView!
    
    @IBOutlet weak var lefthandView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.primaryLabel.text = ""
        self.secondaryLabel.text = ""
        self.unattributedTitle = self.primaryLabel.text! + " $12,000"
        self.highlightCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshView()
    }
    
    public func refreshView() {
        self.refreshCell()
        self.highlightCell()
        
        if let del = delegate {
            let idx = del.selectedAircraftIndex()
            if idx == self.view.tag {
                self.highlightBackground()
            }
        }
    }
    
    @IBAction func aircraftSelectionTapAction(_ sender: UITapGestureRecognizer) {
        delegate?.aircraftWasSelected(atIndex: self.view.tag)
        
        refreshCell()
        highlightCell()
        highlightBackground()
    }
    
    func refreshCell() {
        
        self.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
        
        self.primaryLabel.text = titleData + costData
        self.unattributedTitle = self.primaryLabel.text
        self.secondaryLabel.text = subtitleData
        
        self.primaryLabel.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
    }
    
    private func applyColorToTitle(color: UIColor) -> NSAttributedString {
        let cost = self.costData
        let titleString = self.titleData
        let title = titleString.uppercased()
        let combined = title + " " + cost
        
        // yellow/gold
        let range = (combined as NSString).range(of: cost)
        let attribute = NSMutableAttributedString.init(string: combined)
        attribute.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        
        // white
        let whiteRange = (combined as NSString).range(of: title)
        attribute.addAttribute(NSForegroundColorAttributeName, value: AppStyle.aircraftSelectScreenCellTextHighlightPrimaryColor , range: whiteRange)
        
        return attribute
    }
    
    private func highlightBackground() {
        self.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
    }
    
    private func highlightCell() {
        if let _ = self.unattributedTitle {
            let attributedString = self.applyColorToTitle(color: AppStyle.aircraftSelectScreenCellTextHighlightSecondaryColor)
            self.primaryLabel.attributedText = attributedString
        }
    }
    
    @IBAction func closeButtonWasTapped(_ sender: Any) {
        delegate?.closeButtonWasTapped()
    }
}
