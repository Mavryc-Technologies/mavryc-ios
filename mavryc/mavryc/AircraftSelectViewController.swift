//
//  AircraftSelectViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AircraftSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var nextButton: StyledButton! {
        didSet{
            // TODO: check trip data to see if enabled nextButton
            nextButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var backgroundImageView: UIImageView! {
        didSet {
            //backgroundImageView.image = AppState.tempBGImageForTransitionAnimationHack
        }
    }
    
    var nextButtonBottomSpaceOriginal: CGFloat = -20.0
    var nextButtonBottomSpaceRetracted: CGFloat = -80.0
    @IBOutlet weak var nextButtonBottomVerticalSpaceConstraint: NSLayoutConstraint! {
        didSet {
            //self.nextButtonBottomSpaceOriginal = nextButtonBottomVerticalSpaceConstraint.constant
        }
    }
    
    
    // MARK: Temp Data
//    var titleData = ["Very Light","Light","MID","SUPER","HEAVY"]
//    var subtitleData = ["Not Available","Not Available","Flight Time: 1hr 32mins","Flight Time: 1hr 24mins","Flight Time: 1hr 12mins"]
//    var costData = ["",""," $12,995.95"," $14,775.00", " $17,445.00"]
    var titleData = ["MID","SUPER","HEAVY"]
    var subtitleData = ["Flight Time: 1hr 32mins","Flight Time: 1hr 24mins","Flight Time: 1hr 12mins"]
    var costData = [" $12,995.95"," $14,775.00", " $17,445.00"]

    var cellWasSelectedAtIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .aircraftSelection)
        tableView.register(UINib(nibName: "AircraftSelectCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .aircraftSelection
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.nextButtonBottomVerticalSpaceConstraint.constant = nextButtonBottomSpaceRetracted
    }
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleData.count    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let customCell = cell as? AircraftSelectCell {
            customCell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
            
            customCell.title.text = titleData[indexPath.row] + costData[indexPath.row]
            customCell.unattributedTitle = customCell.title.text
            customCell.subtitle.text = subtitleData[indexPath.row]
            
            customCell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
            
            if let selectedCellIndexPath = cellWasSelectedAtIndexPath {
                if selectedCellIndexPath == indexPath {
                    highlightCell(cell: customCell, indexPath: indexPath)
                    highlightCellBackground(cell: customCell)
                } else {
                    delightCell(cell: customCell) // turns off highlight for rest of cells once a cell is selected
                }
            } else {
                highlightCell(cell: customCell, indexPath: indexPath)
            }
            
            return customCell
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I was tapped")
        
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            if cell.isSelected {
                
                cellWasSelectedAtIndexPath = indexPath
                
                cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
                cell.title.textColor = AppStyle.aircraftSelectScreenCellTextHighlightPrimaryColor
                
                highlightCell(cell: cell, indexPath: indexPath)
                
                nextButton.isEnabled = true
                
                // reload
                tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            delightCell(cell: cell)
        }
    }
    
    private func highlightCellBackground(cell: AircraftSelectCell) {
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
    }
    
    private func highlightCell(cell: AircraftSelectCell, indexPath: IndexPath) {
        if let _ = cell.unattributedTitle {
            let attributedString = self.applyColorToTitle(indexPath: indexPath, color: AppStyle.aircraftSelectScreenCellTextHighlightSecondaryColor)
            cell.title.attributedText = attributedString
        }
    }
    
    private func delightCell(cell: AircraftSelectCell) {
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
        cell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
        cell.title.attributedText = nil
        cell.title.text = cell.unattributedTitle
        cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
    }
    
    private func applyColorToTitle(indexPath: IndexPath, color: UIColor) -> NSAttributedString {
        let cost = costData[indexPath.row]
        let title = titleData[indexPath.row]
        let combined = title + cost
        let range = (combined as NSString).range(of: cost)
        let attribute = NSMutableAttributedString.init(string: combined)
        attribute.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attribute
    }
}

extension AircraftSelectViewController: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {
        
    }
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
    
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {
    }
}
