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
    
    
    @IBOutlet weak var phoneIconImageView: UIImageView!
    
    @IBOutlet weak var contactsIconImageView: UIImageView!

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
    fileprivate var contactsDictionary: [String:Any] = [:]
    fileprivate var contactsSectionTitles: [String] = []
    fileprivate let abcIndexTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    
    private func updateData(list: [String]) {
        
        // TODO: remove when not needed
        self.data = list
        
        // TODO: process the data into a indexedAlphabeticalDictionary
        let sorted = list.sorted()
        
        contactsDictionary.removeAll()
        contactsSectionTitles.removeAll()
        
        abcIndexTitles.forEach { (letter) in
            let matches = sorted.filter({ (candidateName) -> Bool in
                if let letterFirst = candidateName.characters.first, let letterChar = letter.characters.first {
                    if letterFirst == letterChar {
                        return true
                    }
                }
                return false
            })
            
            if matches.count > 0 {
                contactsSectionTitles.append(letter)
                contactsDictionary[letter] = matches
            }
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ContactTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")

        self.fetchInitialContactsAndUpdate()
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
        return self.contactsSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactsSectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return data.count
        
        let sectionTitle: String = contactsSectionTitles[section]
        if let sectionNames: [Any] = contactsDictionary[sectionTitle] as? [Any] {
            return sectionNames.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let letterKey = contactsSectionTitles[indexPath.section]
        guard let theContacts: [Any] = contactsDictionary[letterKey] as? [Any] else { return }
        guard let selectedContactName = theContacts[indexPath.row] as? String else { return }
        
        //let phone = self.data[indexPath.row]
        let phone = selectedContactName
        let email = ""
        let skContact = SkylarContact(firstname: "tom", lastname: "thumb", phone: phone, email: email)
        delegate?.contactPicker(contactPicker: self, didSelectContact: skContact)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ContactTableViewCell else { return UITableViewCell() }
        
        //cell.textLabel?.textColor = UIColor.white
        //cell.textLabel?.font = UIFont(name: "Lato-Light", size: 8.0)
        
        let sectionTitle: String = contactsSectionTitles[indexPath.section]
        if let sectionNames: [Any] = contactsDictionary[sectionTitle] as? [Any] {
            if let nameAtIndex = sectionNames[indexPath.row] as? String {
                cell.title?.text = nameAtIndex
            }
        }
        
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactsSectionTitles
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        //view.tintColor = AppStyle.skylarDeepBlue
//        view.backgroundColor = AppStyle.skylarDeepBlue
        view.tintColor = AppStyle.skylarDeepBlue
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.textLabel?.font = UIFont(name: "Lato", size: 12.0)
    }
}

extension ContactPickerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let id = textField == self.contactSearchTextField ? "contacts" : "add number"
        print("\(id) textFieldDidBeginEditing: \(String(describing: textField.text))")
        
        if id == "contacts" {
            self.contactsIconImageView.isHighlighted = true
            self.phoneIconImageView.isHighlighted = false
            self.contactSearchTextField.textColor = UIColor.white
            self.phoneNumberTextField.textColor = AppStyle.skylarBlueGrey
        } else {
            self.phoneIconImageView.isHighlighted = true
            self.contactsIconImageView.isHighlighted = false
            self.phoneNumberTextField.textColor = UIColor.white
            self.contactSearchTextField.textColor = AppStyle.skylarBlueGrey
        }
        
        if id == "contacts" {
            if let str = textField.text {
                if str.characters.count > 0 {
                    self.fetchAndUpdateTableWithContactsMatching(term: str)
                }
            }
        }
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
        }
            
        else if textField == self.contactSearchTextField {
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
        print("replacementString: \(string)")
        if let currText = textField.text {
            let searchTerm = currText + string
            if searchTerm.characters.count > 0 {
                self.fetchAndUpdateTableWithContactsMatching(term: searchTerm)
            }
        }
        return true
    }
    
    func deselectSearchControls() {
        self.contactSearchTextField.resignFirstResponder()
        self.phoneNumberTextField.resignFirstResponder()
    }
}

