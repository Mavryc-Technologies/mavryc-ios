//
//  AircraftDetailViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/28/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AircraftDetailViewController: UIViewController {

    // MARK: - Properties
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
    
    
    @IBOutlet weak var lefthandView: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func selectionTapAction() {
        
        self.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
        
        self.primaryLabel.text = titleData + costData
        self.unattributedTitle = self.primaryLabel.text
        self.secondaryLabel.text = subtitleData
        
        self.primaryLabel.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
    }
    
    private func applyColorToTitle(color: UIColor) -> NSAttributedString {
        let cost = self.costData
        let title = self.titleData
        let combined = title + cost
        
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
}
