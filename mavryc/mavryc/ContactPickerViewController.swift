//
//  ContactPickerViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/25/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import Contacts

protocol ContactPickerProtocol {
    
    func contactPicker(contactPicker: ContactPickerViewController, closeButtonWasTapped: Bool)
    func contactPicker(contactPicker: ContactPickerViewController, didSelectContact: SkylarContact)
}

class ContactPickerViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: ContactPickerProtocol?
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
        }
    }
    
    // MARK: - Datasource support
    fileprivate var data: [String] = [] // replace String with CNContact
    
    private func updateData(list: [String]) {
        self.data = list
        self.tableView.reloadData()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        
        let list = ["bobert", "dilbert", "dogbert", "elmo", "cheapcheap"]
        self.updateData(list: list)
    }
    
    
    // MARK: - Control Actions
    
    @IBAction func closeButtonTapAction(_ sender: UITapGestureRecognizer) {
        delegate?.contactPicker(contactPicker: self, closeButtonWasTapped: true)
    }
}

extension ContactPickerViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phone = self.data[indexPath.row]
        let email = ""
        let skContact = SkylarContact(firstname: "jimb", lastname: "jomb", phone: phone, email: email)
        delegate?.contactPicker(contactPicker: self, didSelectContact: skContact)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if data.count >= indexPath.row {
            let string = data[indexPath.row]
            cell.textLabel?.text = string
        }
        
        return cell
    }
}
