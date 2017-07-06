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
        
        //self.tableView.separatorColor = AppStyle.airportSearchTableViewSeparatorColor
        self.tableView.separatorStyle = .none
        
        // make list of dates starting today through next 7 days
        let today = Date()
        let tomorrow = (Calendar.current as NSCalendar).date(byAdding: .day, value: 1, to: Date(), options: [])!
        let tomorrow2 = (Calendar.current as NSCalendar).date(byAdding: .day, value: 2, to: Date(), options: [])!
        let tomorrow3 = (Calendar.current as NSCalendar).date(byAdding: .day, value: 3, to: Date(), options: [])!
        let tomorrow4 = (Calendar.current as NSCalendar).date(byAdding: .day, value: 4, to: Date(), options: [])!
        let tomorrow5 = (Calendar.current as NSCalendar).date(byAdding: .day, value: 5, to: Date(), options: [])!
        let tomorrow6 = (Calendar.current as NSCalendar).date(byAdding: .day, value: 6, to: Date(), options: [])!
        
        let list = ["\(today.toString()) (today)", "\(tomorrow.toString()) (tomorrow)", "\(tomorrow2.toString())", "\(tomorrow3.toString())", "\(tomorrow4.toString())", "\(tomorrow5.toString())", "\(tomorrow6.toString())"]
        
        self.updateData(list: list)
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

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter.string(from: self)
    }
}
