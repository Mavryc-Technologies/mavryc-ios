//
//  AircraftSelectViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class AircraftSelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var nextButton: StyledButton! {
        didSet{
            // TODO: check trip data to see if enabled nextButton
            nextButton.isEnabled = false
        }
    }
    
    // MARK: - Temp Data
    var titleData = ["Very Light","Light","MID","SUPER","HEAVY"]
    var subtitleData = ["Not Available","Not Available","Flight Time: 1hr 32mins","Flight Time: 1hr 24mins","Flight Time: 1hr 12mins"]
    var costData = ["",""," $12,995.95"," $14,775.00", " $17,445.00"]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AircraftSelectCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let customCell = cell as? AircraftSelectCell {
            customCell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
            
            customCell.title.text = titleData[indexPath.row] + costData[indexPath.row]
            customCell.unattributedTitle = customCell.title.text
            customCell.subtitle.text = subtitleData[indexPath.row]
            
            customCell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("I was tapped")
        
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            if cell.isSelected {
                cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellHighlightColor
                cell.title.textColor = AppStyle.aircraftSelectScreenCellTextHighlightPrimaryColor
                
                if let _ = cell.unattributedTitle {
                    let attributedString = self.applyColorToTitle(indexPath: indexPath, color: AppStyle.aircraftSelectScreenCellTextHighlightSecondaryColor)
                    cell.title.attributedText = attributedString
                }
                
                nextButton.isEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AircraftSelectCell {
            cell.lefthandView.backgroundColor = AppStyle.aircraftSelectScreenCellNormalColor
            cell.title.textColor = AppStyle.aircraftSelectScreenCellTextNormalColor
            cell.title.attributedText = nil
            cell.title.text = cell.unattributedTitle
        }
    }
    
    func applyColorToTitle(indexPath: IndexPath, color: UIColor) -> NSAttributedString {
        let cost = costData[indexPath.row]
        let title = titleData[indexPath.row]
        let combined = title + cost
        let range = (combined as NSString).range(of: cost)
        let attribute = NSMutableAttributedString.init(string: combined)
        attribute.addAttribute(NSForegroundColorAttributeName, value: color , range: range)
        return attribute
    }
}
