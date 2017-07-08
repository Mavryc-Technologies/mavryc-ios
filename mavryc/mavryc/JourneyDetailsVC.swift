//
//  JourneyDetailsVC.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

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
    
    @IBOutlet weak var arrivalIconImageView: UIImageView!
    
    @IBOutlet weak var departureIconImageView: UIImageView!
    
    weak var datePickerTVC: DatePickerTableViewController?
    
    @IBOutlet weak var datePickerContainer: UIView! {
        didSet {
            datePickerContainer.backgroundColor = AppStyle.skylarDeepBlue
        }
    }
    
    @IBOutlet weak var datePickerContainerStackView: UIStackView!
    
    
    @IBOutlet weak var dateTextField: UILabel! {
        didSet {
            dateTextField.text = Date.todayString() + " (today)"
        }
    }
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(userLocationDidUpdate), name: Notification.Name.Location.UserLocationDidUpdate, object: nil)
        
        self.deselectSearchControls()
        
        self.setupSwipeGesture()
        
        self.datePickerContainerStackView.isHidden = true
    }
    
    func setupSwipeGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeRight.direction = .right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    func handleGesture(gesture: UISwipeGestureRecognizer) -> Void {
        if gesture.direction == UISwipeGestureRecognizerDirection.right {
            print("Swipe Right")
            ScreenNavigator.sharedInstance.navigateBackward()
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.left {
            print("Swipe Left")
            if nextButton.isEnabled {
                self.performSegue(withIdentifier: "AircraftSelectionScreenSegue", sender: self)
            }
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.up {
            print("Swipe Up")
        }
        else if gesture.direction == UISwipeGestureRecognizerDirection.down {
            print("Swipe Down")
            ScreenNavigator.sharedInstance.closePanel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup based on current screen state
        super.viewWillAppear(animated)
        ScreenNavigator.sharedInstance.currentPanelScreen = .journey
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Notification Handlers
    
    @objc private func userLocationDidUpdate(notification: Notification) {

        if let location = notification.userInfo?["location"] as? CLLocation {
            print("\(location)")
            
            self.updateTripRecord(departure: location, updateDepartureField: true)
        }
    }
    
    func updateTripRecord(departure location: CLLocation, updateDepartureField: Bool) {
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                print("🐸--- user location did Update: \(placemark)")
                
                guard let airportCityString = self.airportString(placemark: placemark) else { return }
                
                if updateDepartureField {
                    self.departureSearchTextField.text = airportCityString
                }
                
                if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
                    print("updating user location, and found current trip-in-planning")
                    trip.flights[0].departureString = airportCityString
                } else {
                    let trip = Trip()
                    let flight = FlightInfo()
                    flight.departureString = airportCityString
                    trip.flights.append(flight)
                    TripCoordinator.sharedInstance.currentTripInPlanning = trip
                }
            }
        }
    }
    
    func airportString(placemark: CLPlacemark) -> String? {
        
        guard let city = placemark.locality else { return nil }
        guard let state = placemark.administrativeArea else { return nil }
        guard let country = placemark.country else { return nil }
        let airportCityStateCountry = "\(city), \(state), \(country)"
        return airportCityStateCountry
    }
    
    @objc private func panelWillOpen() {
        print("panelWillOpen notification handler called")
    }
    
    @objc private func panelDidOpen() {
        print("panelDidOpen notification handler called")
        
        if ScreenNavigator.destinationSearchButtonWasPressedState {
            arrivalSearchTextField.becomeFirstResponder()
        }
    }
    
    @objc private func panelWillClose() {
        print("panelWillClose notification handler called")
        
        self.deselectSearchControls()
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
    
    
    @IBAction func dateTapAction(_ sender: Any) {
        print("tapped date section")
        
        // if date picker is visible, hide it 
        // else show it
        UIView.animate(withDuration: 0.15) {
            if self.datePickerContainerStackView.isHidden  {
                self.datePickerContainerStackView.isHidden = false
            } else {
                self.datePickerContainerStackView.isHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func myLocationTapAction(_ sender: UITapGestureRecognizer) {
        
        if let myLoc = LocationController.lastKnownUserLocation {
            
            self.updateTripRecord(departure: myLoc, updateDepartureField: true)
            
            if self.departureSearchTextField.isFirstResponder {
                self.deselectSearchControls()
            }
        } // TODO: consider adding else support to refresh location request anew.
    }
    
    @IBAction func mainViewTapAction(_ sender: UITapGestureRecognizer) {
        self.deselectSearchControls()
    }
    
    
    // MARK: - Search Control Support
    func triggerDepartureList() {
        
        let isOpening = self.departureTableViewHeightConstraint.constant == 0
        
        UIView.animate(withDuration: 0.25) {
            if isOpening {
                self.arrivalTableViewHeightConstraint.constant = 0
                self.departureTableViewHeightConstraint.constant = 600
            } else {
                self.departureTableViewHeightConstraint.constant = 0
            }
            self.view.layoutIfNeeded()
        }
        
        if isOpening {
            departureSearchTextField.becomeFirstResponder()
        } else {
            departureSearchTextField.resignFirstResponder()
        }
    }

    func triggerArrivalList() {
        
        let isOpening = (self.arrivalTableViewHeightConstraint.constant == 0 || ScreenNavigator.destinationSearchButtonWasPressedState)
        
        UIView.animate(withDuration: 0.25) {
            if ScreenNavigator.destinationSearchButtonWasPressedState {
                ScreenNavigator.destinationSearchButtonWasPressedState = false
                self.arrivalTableViewHeightConstraint.constant = 600
                self.departureTableViewHeightConstraint.constant = 0
            } else {
                if self.arrivalTableViewHeightConstraint.constant == 0 {
                    self.arrivalTableViewHeightConstraint.constant = 600
                    self.departureTableViewHeightConstraint.constant = 0
                } else {
                    self.arrivalTableViewHeightConstraint.constant = 0
                }
            }
            self.view.layoutIfNeeded()
        }
        
        if isOpening {
            arrivalSearchTextField.becomeFirstResponder()
        } else {
            arrivalSearchTextField.resignFirstResponder()
        }
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
        
//        let source = Cities.shared
        let source = GooglePlacesClient.sharedInstance
        source.autoCompletionSuggestions(for: text, predictions: { list in
            
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
        } else if segue.identifier == "datePickerTVCSegue" {
            if let tvc = segue.destination as? DatePickerTableViewController {
                self.datePickerTVC = tvc
                tvc.datePickerListDelegate = self
            }
        }
    }
}

extension JourneyDetailsVC: DatePickerTableViewDelegate {
    
    func didSelectDate(string: String, date: Date) {

        print("date was selected: \(string)")
        self.dateTextField.text = string
        
        // update the date
        UIView.animate(withDuration: 0.15) {
            self.datePickerContainerStackView.isHidden = true
            self.view.layoutIfNeeded()
        }
    }
}

extension JourneyDetailsVC: AirportSearchListDelegate {
    
    func airportSearchListItemWasSelected(airportName: String) {

        if self.arrivalSearchTextField.isFirstResponder {
            arrivalSearchTextField.text = airportName
            // TODO: update trip data model for arrival airport
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].arrivalString = airportName
            updateSearchControlUIForState(control: arrivalSearchTextField)
            
        } else if self.departureSearchTextField.isFirstResponder {
            departureSearchTextField.text = airportName
            updateSearchControlUIForState(control: departureSearchTextField)
            // TODO: update trip data model for departure airport
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].departureString = airportName
            
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
    
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {
    }
}

extension JourneyDetailsVC: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = Date.todayString()
        //Lato-Regular
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 14.0)!, NSForegroundColorAttributeName:UIColor.white])
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = self.pickerView(pickerView, attributedTitleForRow: row, forComponent: component)
        let string = text?.string
        self.dateTextField.text = string
        print("did select row \(Date())")
        self.dateTapAction(self) // collapses the pickerview if visible
    }
    
    var nextSixDays: Date {
        let dt = (Calendar.current as NSCalendar).date(byAdding: .day, value: 8, to: Date(), options: [])!
        return (Calendar.current as NSCalendar).date(byAdding: .day, value: 8, to: Date(), options: [])!
    }
    
    var previousSixDays: Date {
        return (Calendar.current as NSCalendar).date(byAdding: .day, value: 8, to: Date(), options: [])!
        //return (Calendar.current as NSCalendar).date
    }
}

extension JourneyDetailsVC: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 8
    }
}

