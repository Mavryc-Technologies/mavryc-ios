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
    
    @IBOutlet weak var contactSearchTextField: UITextField! {
        didSet {
            contactSearchTextField.delegate = self
            contactSearchTextField.keyboardAppearance = .dark
            
            let placeholder = NSAttributedString(string: "Search Contacts", attributes: [NSForegroundColorAttributeName:AppStyle.skylarBlueGrey])
            contactSearchTextField.attributedPlaceholder = placeholder
            
            contactSearchTextField.tintColor = AppStyle.skylarBlueGrey
            
            contactSearchTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        }
    }

    @IBOutlet weak var phoneNumberTextField: UITextField! {
        didSet {
            phoneNumberTextField.delegate = self
            phoneNumberTextField.keyboardAppearance = .dark
            
            let placeholder = NSAttributedString(string: "Add Phone Number", attributes: [NSForegroundColorAttributeName:AppStyle.skylarBlueGrey])
            phoneNumberTextField.attributedPlaceholder = placeholder
            
            phoneNumberTextField.tintColor = AppStyle.skylarBlueGrey
            
            phoneNumberTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        }
    }
    
    func didChangeText(textField: UITextField) {
//        if let text = textField.text {
//            //self.updateListWithAutocompleteSuggestions(text: text, searchControl: textField)
//        }
    }
    
    @IBOutlet weak var contactSearchFieldView: UIView! {
        didSet {
            contactSearchFieldView.layer.cornerRadius = 6
        }
    }
    
    @IBOutlet weak var phoneFieldView: UIView! {
        didSet {
            phoneFieldView.layer.cornerRadius = 6
        }
    }
    
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

        self.fetchInitialContactsAndUpdate()
//        let list = ["bobert", "dilbert", "dogbert", "elmo", "cheapcheap"]
//        self.updateData(list: list)
    }
    
    func fetchInitialContactsAndUpdate() {
        
        DispatchQueue.global(qos: .background).async {
            // Do some background work
            let store = CNContactStore()
            store.requestAccess(for: .contacts, completionHandler: { (success, err) in
                if success {

                    let pred = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())
                    
                    let contacts = try! store.unifiedContacts(matching: pred, keysToFetch:[CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
                    
                    var nameList: [String] = []
                    contacts.forEach({ (contact) in
                        let fullName = contact.givenName + " " + contact.familyName
                        if fullName.characters.count > 2 {
                            nameList.append(fullName)
                        }
                    })
                    
                    DispatchQueue.main.async {
                        self.updateData(list: nameList)
                    }
                }
            })
        }
    }

    func fetchAndUpdateTableWithContactsMatching(term: String) {
        
        DispatchQueue.global(qos: .background).async {
            // Do some background work
            let store = CNContactStore()
            let pred = CNContact.predicateForContacts(matchingName: term)

            let contacts = try! store.unifiedContacts(matching: pred, keysToFetch:[CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor])
            
            var nameList: [String] = []
            contacts.forEach({ (contact) in
                let fullName = contact.givenName + " " + contact.familyName
                if fullName.characters.count > 2 {
                    nameList.append(fullName)
                }
            })
            
            DispatchQueue.main.async {
                self.updateData(list: nameList)
            }
        }
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
    
    func filterTableView(filterString: String) {
        // TODO: show only contacts matching this string
    }
}

extension ContactPickerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let id = textField == self.contactSearchTextField ? "contacts" : "add number"
        print("\(id) textFieldDidBeginEditing: \(String(describing: textField.text))")
        
//        if id == "contacts" {
//            //self.triggerArrivalList()
//        } else {
//            //self.triggerDepartureList()
//        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let id = textField == self.contactSearchTextField ? "contacts" : "add number"
        print("\(id) textFieldDidEndEditing: \(String(describing: textField.text))")
        
        if id == "contacts" {
            if let str = textField.text {
                if str.characters.count > 0 {
                    self.fetchAndUpdateTableWithContactsMatching(term: str)
                }
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let id = textField == self.contactSearchTextField ? "contacts" : "add number"
        print("\(id) textFieldShouldBeginEditing: \(String(describing: textField.text))")
        
        if textField == self.phoneNumberTextField {
//            if self.preventEditBecauseDepartureAirportWasSelected {
//                self.preventEditBecauseDepartureAirportWasSelected = false
//                return false
//            }
        }
            
        else if textField == self.contactSearchTextField {
//            if self.preventEditBecauseDestinationAirportWasSelected {
//                self.preventEditBecauseDestinationAirportWasSelected = false
//                return false
//            }
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        //updateSearchControlUIForState(control: textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let id = textField == self.contactSearchTextField ? "contacts" : "add number"

        if id == "contacts" {
            // TODO: filter the contacts by this string
        } else {
            // process phone number
            // validate phone number
            if (textField.text?.characters.count)! > 6 {
                let skylarContact = SkylarContact(firstname: "", lastname: "", phone: textField.text, email: "")
                delegate?.contactPicker(contactPicker: self, didSelectContact: skylarContact)
            } else {
                return false
            }
        }
        
        self.deselectSearchControls()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func deselectSearchControls() {
        self.contactSearchTextField.resignFirstResponder()
        self.phoneNumberTextField.resignFirstResponder()
    }
}

