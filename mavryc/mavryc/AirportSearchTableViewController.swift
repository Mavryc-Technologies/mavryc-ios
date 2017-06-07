//
//  AirportSearchTableViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/1/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

enum AirportSearchType {
    case departure
    case destination
}

protocol AirportSearchListDelegate {
    
    func airportSearchListItemWasSelected(airportName: String)
    
    /// returns type of list
    func airportSearchListType(controller: AirportSearchTableViewController) -> AirportSearchType
}

class AirportSearchTableViewController: UITableViewController {
    
    public var listDelegate: AirportSearchListDelegate? = nil
    
//    public var isListVisible = false
    
    // MARK: - Datasource support
    
    private var data: [Any] = []
    
    public func updateListWithAirports(list: [Any]) {
        self.data = list
        self.tableView.reloadData()
    }

    public func clearList() {
        self.data = []
        self.tableView.reloadData()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorColor = AppStyle.airportSearchTableViewSeparatorColor

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath)

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
                cell.backgroundColor = AppStyle.airportSearchCellSelectionColor
            } else {
                cell.backgroundColor = UIColor.clear
            }
            
            if let text = cell.textLabel?.text {
                self.listDelegate?.airportSearchListItemWasSelected(airportName: text)
            }
        }
    }
}
