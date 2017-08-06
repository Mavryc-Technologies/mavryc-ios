//
//  OutboundReturnViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/2/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import ObjectMapper
import CoreLocation

@IBDesignable
class OutboundReturnViewController: UIViewController {

    // MARK: - Properties
    
    weak var screenCompletableDelegate: ScreenCompletable? = nil

    
    @IBInspectable var isOutboundController: Bool = true {
        didSet {
            if isOutboundController {
                // add anything additional depending on this value
            } else {
                // add anything additional depending on this value
            }
        }
    }
    
    weak var departureSearchList: AirportSearchTableViewController? = nil
    weak var destinationSearchList: AirportSearchTableViewController? = nil
    
    var preventEditBecauseDepartureAirportWasSelected = false
    var preventEditBecauseDestinationAirportWasSelected = false
    
    
    // MARK: - Outlet Properties
    
    // Stack Views
    @IBOutlet weak var departureControlVertStackView: UIStackView!
    @IBOutlet weak var arrivalControlVertStackView: UIStackView!
    @IBOutlet weak var DateControlVertStackView: UIStackView!
    @IBOutlet weak var timeControlVertStackView: UIStackView!
    @IBOutlet weak var paxControlVertStackView: UIStackView!
    
    var isTripOneWayOnly: Bool = true
    @IBOutlet weak var addRemoveReturnTripButton: UIImageView!
    @IBOutlet weak var addTripLabel: UILabel!
    
    // Departure Search Text Field
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
    
    // Destination Search Text Field
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
    
    @IBOutlet weak var datePickerContainer: UIView! {
        didSet {
            datePickerContainer.backgroundColor = AppStyle.skylarDeepBlue
            datePickerContainer.layer.cornerRadius = 4
        }
    }
    
    weak var datePickerTVC: DatePickerTableViewController?
    @IBOutlet weak var datePickerContainerStackView: UIStackView!
    @IBOutlet weak var dateTextField: UILabel! {
        didSet {
            dateTextField.text = Date.todayString() + " (today)"
        }
    }
    
    // Time Control
    @IBOutlet weak var timeControl: PaxPicker! {
        didSet {
            timeControl.delegate = self
        }
    }
    
    // Pax Control
    @IBOutlet weak var paxControl: PaxPicker! {
        didSet {
            paxControl.delegate = self
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.deselectSearchControls()
        self.datePickerContainerStackView.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addOrCloseWasTapped),
                                               name: Notification.Name.SubscreenEvents.OutboundReturnAddOrCloseButtonTap,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshUI()
    }
    
    func refreshUI() {
        if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
            if self.isOutboundController {
                let arrivalString = trip.flights[0].arrivalString
                self.arrivalSearchTextField.text = arrivalString
                let departureString = trip.flights[0].departureString
                self.departureSearchTextField.text = departureString
            } else {
                let arrivalString = trip.flights[1].arrivalString
                self.arrivalSearchTextField.text = arrivalString
                let departureString = trip.flights[1].departureString
                self.departureSearchTextField.text = departureString
            }
        }
    }
    
    // MARK: - action support
    @objc private func addOrCloseWasTapped(notif: NSNotification) {
        if let userInfo = notif.userInfo as? [String: Int] {
            if let isOneWayOnlyFlag = userInfo[Notification.Name.SubscreenEvents.oneWayOnlyKey] {
                let isOneWay = isOneWayOnlyFlag == 1 ? true : false
                let labelString = isOneWay ? "ADD RETURN" : "REMOVE RETURN"
                self.addTripLabel.text = labelString
                self.updateAddTripButton(showAddButton: isOneWay)
            }
        }
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
                self.screenCompletableDelegate?.screenProgressDidUpdate(screen: self, isValidComplete: false)
            } else {
                self.datePickerContainerStackView.isHidden = true
                self.screenCompletableDelegate?.screenProgressDidUpdate(screen: self, isValidComplete: true)
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
        }
    }
    
    @IBAction func mainViewTapAction(_ sender: UITapGestureRecognizer) {
        self.deselectSearchControls()
    }
    
    func clearAllControlValues() {
        departureSearchTextField.text = nil
        arrivalSearchTextField.text = nil
        dateTextField.text = Date.todayString() + " (today)"
        paxControl.updateBarValue(bar: 1)
        timeControl.updateBarValue(bar: 1)
    }
    
    // MARK: - Control Support
    
    @IBAction func AddRemoveReturnTapAction(_ sender: UITapGestureRecognizer) {
        
        if let trip = TripCoordinator.sharedInstance.currentTripInPlanning {
            let isOneWay = !trip.isOneWayOnly // invert
            trip.isOneWayOnly = isOneWay
            let oneWay = isOneWay ? 1 : 0
            NotificationCenter.default.post(name: Notification.Name.SubscreenEvents.OutboundReturnAddOrCloseButtonTap, object: self, userInfo:[Notification.Name.SubscreenEvents.oneWayOnlyKey:oneWay])
        }
    }
    
    // MARK: Return Trip Support
    
    func updateAddTripButton(showAddButton: Bool) {
        if let image = showAddButton ? UIImage(named: "AddButton") : UIImage(named: "AddButtonClose") {
            self.addRemoveReturnTripButton.image = image
        }
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
    
    // MARK: - Data Model Update
    
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
                    let index = self.isOutboundController == true ? 0 : 1
                    trip.flights[index].departureString = airportCityString
                    if let seatCount = self.paxControl.PaxCountLabel.text {
                        trip.flights[index].pax = Int(seatCount)
                    }
                } else {
                    let trip = Trip()
                    let flight = FlightInfo()
                    let returnTrip = FlightInfo()
                    flight.departureString = airportCityString
                    flight.pax = 1
                    trip.flights.append(flight)
                    trip.flights.append(returnTrip)
                    TripCoordinator.sharedInstance.currentTripInPlanning = trip
                }
            }
        }
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
    
    func airportString(placemark: CLPlacemark) -> String? {
        
        guard let city = placemark.locality else { return nil }
        guard let state = placemark.administrativeArea else { return nil }
        guard let country = placemark.country else { return nil }
        let airportCityStateCountry = "\(city), \(state), \(country)"
        return airportCityStateCountry
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
        let source = GooglePlacesClient.sharedInstance
        source.autoCompletionSuggestions(for: text, predictions: { list in
            
            if searchControl == self.arrivalSearchTextField {
                self.destinationSearchList?.updateListWithAirports(list: list)
            } else {
                self.departureSearchList?.updateListWithAirports(list: list)
            }
        })
    }
}


// MARK: - PaxPickerDelegate extension

extension OutboundReturnViewController: PaxPickerDelegate {
    
    func paxPicker(paxPicker: PaxPicker, didUpdateBarValue: Int) {
        let index = self.isOutboundController == true ? 0 : 1
        if paxPicker.isTimeControl {
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].time = didUpdateBarValue
        } else {
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].pax = didUpdateBarValue
        }
    }
    
    func totalBarsAllowedForPaxPicker(paxPicker: PaxPicker) -> Int {
        if paxPicker.isTimeControl {
            return 24
        } else {
            return 16 // for now we're defaulting to 16 until we have server integration to give us an operator's defualt seat amount
        }
    }
}


// MARK: -  DatePickerTableViewDelegate extension

extension OutboundReturnViewController: DatePickerTableViewDelegate {
    
    func didSelectDate(string: String, date: Date) {
        
        print("date was selected: \(string)")
        self.dateTextField.text = string
        
        let index = self.isOutboundController == true ? 0 : 1
        TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].date = string
        
        // update the date
        UIView.animate(withDuration: 0.15) {
            self.datePickerContainerStackView.isHidden = true
            self.view.layoutIfNeeded()
        }
        
        self.screenCompletableDelegate?.screenProgressDidUpdate(screen: self, isValidComplete: true)
    }
}


// MARK: - AirportSearchListDelegate extension

extension OutboundReturnViewController: AirportSearchListDelegate {
    
    func airportSearchListItemWasSelected(airportName: String) {
        
        let index = self.isOutboundController == true ? 0 : 1
        
        if self.arrivalSearchTextField.isFirstResponder {
            arrivalSearchTextField.text = airportName
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].arrivalString = airportName
            if index == 0 {
                TripCoordinator.sharedInstance.currentTripInPlanning?.flights[1].departureString = airportName
                let returnArrival = departureSearchTextField.text
                TripCoordinator.sharedInstance.currentTripInPlanning?.flights[1].arrivalString = returnArrival
            }
            updateSearchControlUIForState(control: arrivalSearchTextField)
            
        } else if self.departureSearchTextField.isFirstResponder {
            departureSearchTextField.text = airportName
            updateSearchControlUIForState(control: departureSearchTextField)
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].departureString = airportName
            
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
                print("get me an image for unlocked state for departure icon")
            }
        }
    }
}


// MARK: - UITextFieldDelegate extension

extension OutboundReturnViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let id = textField == self.arrivalSearchTextField ? "arrival" : "departure"
        print("\(id) textFieldDidBeginEditing: \(String(describing: textField.text))")
        
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
}

