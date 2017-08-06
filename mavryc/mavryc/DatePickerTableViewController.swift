//
//  DatePickerTableViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/5/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

protocol DatePickerTableViewDelegate {
    func didSelectDate(string: String, date: Date)
}

class DatePickerTableViewController: UITableViewController {

    public var datePickerListDelegate: DatePickerTableViewDelegate? = nil
    
    // MARK: - Datasource support
    
    private var data: [Any] = []
    
    private func updateData(list: [Any]) {
        self.data = list
        self.tableView.reloadData()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        
        var loopedList: [Any] = []
        let loopedToday = Date()
        for i in 0...200 {
            if i == 0 {
                loopedList.append(loopedToday.toString() + " (today)")
                continue
            } else {
                let nextDay = (Calendar.current as NSCalendar).date(byAdding: .day, value: i, to: Date(), options: [])!
                if i == 1 {
                    let formattedDay = "\(nextDay.toString()) (tomorrow)"
                    loopedList.append(formattedDay)
                    continue
                }
                
                loopedList.append(nextDay.toString())
            }
        }
        
        self.updateData(list: loopedList)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath)
        
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        
        cell.backgroundColor = UIColor.clear
        
        if data.count >= indexPath.row {
            if let string = data[indexPath.row] as? String {
                cell.textLabel?.text = string
            }
        }
        
        let row = indexPath.row + 1
        let diff = (row < 5) ? row : 5
        let color = AppStyle.skylarBlueGrey
        let alpha = CGFloat(1 - (CGFloat(diff) * 0.1))
        cell.textLabel?.textColor = color.withAlphaComponent(alpha)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = UIColor.clear
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.isSelected {
                cell.backgroundColor = UIColor.clear
                //cell.backgroundColor = AppStyle.airportSearchCellSelectionColor
            } else {
                //cell.backgroundColor = UIColor.clear
                cell.backgroundColor = UIColor.clear
            }
            
            if let text = cell.textLabel?.text {
                // TODO: get the actual date and pass it
                self.datePickerListDelegate?.didSelectDate(string: text, date: Date())
            }
        }
    }
}
