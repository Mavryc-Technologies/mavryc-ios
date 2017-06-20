//
//  JourneyDetailsVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit


class JourneyDetailsVC: UIViewController {

    // MARK: Properties
    weak var departureSearchList: AirportSearchTableViewController? = nil
    weak var destinationSearchList: AirportSearchTableViewController? = nil
    
    var preventEditBecauseDepartureAirportWasSelected = false
    var preventEditBecauseDestinationAirportWasSelected = false
    
    // MARK: Outlet Properties
    @IBOutlet weak var nextButton: StyledButton! {
        didSet {
            nextButton.isEnabled = true
        }
    }
    
    @IBOutlet weak var oneWayReturnSegmentControl: UISegmentedControl! {
        didSet {
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerHighlightTextColor], for: UIControlState.selected)
            
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerNormalTextColor], for: UIControlState.normal)
        }
    }
    
    @IBOutlet weak var departureSearchTextField: UITextField! {
        didSet {
            departureSearchTextField.delegate = self
            departureSearchTextField.keyboardAppearance = .dark
            
            let placeholder = NSAttributedString(string: "From Where?", attributes: [NSForegroundColorAttributeName:AppStyle.skylarBlueGrey])
            departureSearchTextField.attributedPlaceholder = placeholder
            
            departureSearchTextField.tintColor = AppStyle.skylarBlueGrey

            departureSearchTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
            
        }
    }
    
    @IBOutlet weak var arrivalSearchTextField: UITextField! {
        didSet {
            arrivalSearchTextField.delegate = self
            arrivalSearchTextField.keyboardAppearance = .dark
            
            let placeholder = NSAttributedString(string: "Where To?", attributes: [NSForegroundColorAttributeName:AppStyle.skylarBlueGrey])
            arrivalSearchTextField.attributedPlaceholder = placeholder
            
            arrivalSearchTextField.tintColor = AppStyle.skylarBlueGrey
            
            arrivalSearchTextField.addTarget(self, action: #selector(didChangeText(textField:)), for: .editingChanged)
        }
    }
    
    func didChangeText(textField: UITextField) {
        if let text = textField.text {
            self.updateListWithAutocompleteSuggestions(text: text, searchControl: textField)
        }
    }
    
    // use to expand or retract departure city/airport list
    @IBOutlet weak var departureTableViewHeightConstraint: NSLayoutConstraint!
    
    // use to expand or retract arrival city/airport list
    @IBOutlet weak var arrivalTableViewHeightConstraint: NSLayoutConstraint!
    
    
    var nextButtonBottomSpaceOriginal: CGFloat = 20.0
    var nextButtonBottomSpaceRetracted: CGFloat = -80.0
    @IBOutlet weak var nextButtonBottomVerticalSpaceConstraint: NSLayoutConstraint! {
        didSet {
            self.nextButtonBottomSpaceOriginal = nextButtonBottomVerticalSpaceConstraint.constant
        }
    }
    
    @IBOutlet weak var arrivalIconImageView: UIImageView!
    
    @IBOutlet weak var departureIconImageView: UIImageView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerScreen(screen: self, asScreen: .journey)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelWillOpen),
                                               name: Notification.Name.PanelScreen.WillOpen,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelDidOpen),
                                               name: Notification.Name.PanelScreen.DidOpen,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(panelWillClose),
                                               name: Notification.Name.PanelScreen.WillClose,
                                               object: nil)
        
        self.deselectSearchControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup based on current screen state
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ScreenNavigator.sharedInstance.currentPanelScreen = .journey
    }
    
    // MARK: - Notification Handlers
    
    @objc private func panelWillOpen() {
        print("panelWillOpen notification handler called")

        self.nextButtonBottomVerticalSpaceConstraint.constant = self.nextButtonBottomSpaceRetracted
        self.nextButton.alpha = 1.0
        self.view.layoutIfNeeded()
    }
    
    @objc private func panelDidOpen() {
        print("panelDidOpen notification handler called")
        
        UIView.animate(withDuration: 0.25) {
            self.nextButtonBottomVerticalSpaceConstraint.constant = self.nextButtonBottomSpaceOriginal
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func panelWillClose() {
        print("panelWillClose notification handler called")
        
        UIView.animate(withDuration: 0.10) {
            self.nextButtonBottomVerticalSpaceConstraint.constant = self.nextButtonBottomSpaceRetracted
            self.nextButton.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Control Actions
    
    @IBAction func nextButtonAction(_ sender: Any) {
        print("next button pressed")
    }
    
    @IBAction func departureIconTapAction(_ sender: Any) {
        print("tapped departure icon")
        self.triggerDepartureList()
    }
    
    @IBAction func arrivalIconTapAction(_ sender: Any) {
        print("tapped arrival icon")
        self.triggerArrivalList()
    }
    
    // MARK: - Search Control Support
    func triggerDepartureList() {
        UIView.animate(withDuration: 0.25) {
            if self.departureTableViewHeightConstraint.constant == 0 {
                self.arrivalTableViewHeightConstraint.constant = 0
                self.departureTableViewHeightConstraint.constant = 600
            } else {
                self.departureTableViewHeightConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        
        departureSearchTextField.becomeFirstResponder()
    }

    func triggerArrivalList() {
        UIView.animate(withDuration: 0.25) {
            if self.arrivalTableViewHeightConstraint.constant == 0 {
                self.arrivalTableViewHeightConstraint.constant = 600
                self.departureTableViewHeightConstraint.constant = 0
            } else {
                self.arrivalTableViewHeightConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        
        arrivalSearchTextField.becomeFirstResponder()
    }
    
    func deselectSearchControls() {
        
        UIView.animate(withDuration: 0.25) { 
            self.arrivalTableViewHeightConstraint.constant = 0
            self.departureTableViewHeightConstraint.constant = 0
            self.view.layoutIfNeeded()
        }

        self.arrivalSearchTextField.resignFirstResponder()
        self.departureSearchTextField.resignFirstResponder()
        
        self.destinationSearchList?.clearList()
        self.departureSearchList?.clearList()
    }
    
    func updateListWithAutocompleteSuggestions(text: String, searchControl: UITextField) {
        
        let source = Cities.shared
        source.autoCompletionSuggestions(for: text, predictions: { list in
//            list.forEach({ (item) in
//                print("autocompletion suggestion: \(item)")
//            })
            
            if searchControl == self.arrivalSearchTextField {
                self.destinationSearchList?.updateListWithAirports(list: list)
            } else {
                self.departureSearchList?.updateListWithAirports(list: list)
            }
        })
    }

    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DestinationSearchListSegue" {
            let tvc = segue.destination as? AirportSearchTableViewController
            tvc?.listDelegate = self
            self.destinationSearchList = tvc
        } else if segue.identifier == "DepartureSearchListSegue" {
            let tvc = segue.destination as? AirportSearchTableViewController
            tvc?.listDelegate = self
            self.departureSearchList = tvc
        }
    }
}

extension JourneyDetailsVC: AirportSearchListDelegate {
    
    func airportSearchListItemWasSelected(airportName: String) {

        if self.arrivalSearchTextField.isFirstResponder {
            arrivalSearchTextField.text = airportName
            // TODO: update trip data model for arrival airport
            updateSearchControlUIForState(control: arrivalSearchTextField)
            
        } else if self.departureSearchTextField.isFirstResponder {
            departureSearchTextField.text = airportName
            updateSearchControlUIForState(control: departureSearchTextField)
            // TODO: update trip data model for departure airport
            
        } else {
            print("this shouldn't happen, if so, we have a bug")
        }
        
        deselectSearchControls()
    }
    
    func airportSearchListType(controller: AirportSearchTableViewController) -> AirportSearchType {
        if controller == self.destinationSearchList {
            return AirportSearchType.destination
        } else {
            return AirportSearchType.departure
        }
    }
    
    func updateSearchControlUIForState(control: UITextField) {
        guard let textString = control.text else { return }
        let isAirportLocked = !textString.isEmpty
        if control == arrivalSearchTextField {
            if isAirportLocked {
                arrivalIconImageView.image = UIImage(named: "ArriveIconFormPDF")
            } else {
                arrivalIconImageView.image = UIImage(named: "ArriveIconUnselected")
            }
        } else if control == departureSearchTextField {
            if isAirportLocked {
                departureIconImageView.image = UIImage(named: "DepartIconFormPDF")
            } else {
                // TODO: update the icon image to reflect unlocked
                print("get me an image for unlocked state for departure icon")
            }
        }
    }
}

extension JourneyDetailsVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let id = textField == self.arrivalSearchTextField ? "arrival" : "departure"
        print("\(id) textFieldDidBeginEditing: \(String(describing: textField.text))")
        
        // TODO: expand appropriate list
        if id == "arrival" {
            self.triggerArrivalList()
        } else {
            self.triggerDepartureList()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let id = textField == self.arrivalSearchTextField ? "arrival" : "departure"
        print("\(id) textFieldDidEndEditing: \(String(describing: textField.text))")
    }
    
    
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        let id = textField == self.arrivalSearchTextField ? "arrival" : "departure"
        print("\(id) textFieldShouldBeginEditing: \(String(describing: textField.text))")
        
        if textField == self.departureSearchTextField {
            if self.preventEditBecauseDepartureAirportWasSelected {
                self.preventEditBecauseDepartureAirportWasSelected = false
                return false
            }
        }

        else if textField == self.arrivalSearchTextField {
            if self.preventEditBecauseDestinationAirportWasSelected {
                self.preventEditBecauseDestinationAirportWasSelected = false
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        // TODO: update the appropriate data model
        updateSearchControlUIForState(control: textField)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateSearchControlUIForState(control: textField)
        self.deselectSearchControls()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    // TODO: pressing return on keyboard will cause the appropriate listed item (if present) to become selected, otherwise, just causes a deselect of the search controls
    
}

extension JourneyDetailsVC: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {
        
    }
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}

