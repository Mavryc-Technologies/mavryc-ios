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
    
    // Stack Views
    @IBOutlet weak var departureControlVertStackView: UIStackView!
    @IBOutlet weak var arrivalControlVertStackView: UIStackView!
    @IBOutlet weak var DateControlVertStackView: UIStackView!
    @IBOutlet weak var timeControlVertStackView: UIStackView!
    @IBOutlet weak var paxControlVertStackView: UIStackView!
    
    // Next Button
    @IBOutlet weak var nextButton: StyledButton! {
        didSet {
            nextButton.isEnabled = true
        }
    }
    
    // Outbound and Return Segment Control
    @IBOutlet weak var oneWayReturnSegmentControl: UISegmentedControl! {
        didSet {
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerHighlightTextColor], for: UIControlState.selected)
            
            oneWayReturnSegmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: AppStyle.journeyDetailsSegmentedControllerNormalTextColor], for: UIControlState.normal)
        }
    }
    
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
    
    // Arrival Search Text Field
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
                    let index = self.isOutboundTripScreen() == true ? 0 : 1
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
                self.nextButton.isHidden = true
            } else {
                self.datePickerContainerStackView.isHidden = true
                self.nextButton.isHidden = false
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
    
    @IBAction func onewayReturnButtonAction(_ sender: Any) {
        
        let oneWayMode = isOutboundTripScreen()
        
        // if return trip depart and dest not extant yet, invert and assign
        let index = oneWayMode == true ? 0 : 1
        if let _ = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].departureString {
            // do nothing
        } else {
            // invert for return trip
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].departureString = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].arrivalString
        }
        
        if let _ = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].arrivalString {
            // do nothing
        } else {
            // invert for return trip
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].arrivalString = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].departureString
        }
        
        self.transitionToScreenMode(outbound: oneWayMode)
    }
    
    // MARK: - Outbound and Return Screen support
    func transitionToScreenMode(outbound: Bool) {
        deselectSearchControls()

        let animFlipDirectionOption = outbound ? UIViewAnimationOptions.transitionFlipFromRight : UIViewAnimationOptions.transitionFlipFromLeft
        
        UIView.transition(with: self.view, duration: 0.3, options: animFlipDirectionOption, animations: {
            self.clearAllControlValues()
            self.refreshControlsForTripState(outbound: outbound)
        }) { (isFlipped) in
        }
    }
    
    func refreshControlsForTripState(outbound: Bool) {
        let index = outbound == true ? 0 : 1
        
        departureSearchTextField.text = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].departureString
        arrivalSearchTextField.text = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].arrivalString
        if let dateString = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].date {
            dateTextField.text = dateString
        }
        if let time = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].time {
            timeControl.updateBarValue(bar: time)
        }
        if let pax = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].pax {
            paxControl.updateBarValue(bar: pax)
        }
    }
    
    func clearAllControlValues() {
        departureSearchTextField.text = nil
        arrivalSearchTextField.text = nil
        dateTextField.text = Date.todayString() + " (today)"
        paxControl.updateBarValue(bar: 1)
        timeControl.updateBarValue(bar: 1)
    }
    
    fileprivate func isOutboundTripScreen() -> Bool {
        let outbound = self.oneWayReturnSegmentControl.selectedSegmentIndex == 0
        return outbound
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
        
        let index = self.isOutboundTripScreen() == true ? 0 : 1
        TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].date = string
        
        // update the date
        UIView.animate(withDuration: 0.15) {
            self.datePickerContainerStackView.isHidden = true
            self.view.layoutIfNeeded()
        }
        
        self.nextButton.isHidden = false
    }
}

extension JourneyDetailsVC: AirportSearchListDelegate {
    
    func airportSearchListItemWasSelected(airportName: String) {

        let index = self.isOutboundTripScreen() == true ? 0 : 1
        
        if self.arrivalSearchTextField.isFirstResponder {
            arrivalSearchTextField.text = airportName
            TripCoordinator.sharedInstance.currentTripInPlanning?.flights[index].arrivalString = airportName
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

extension JourneyDetailsVC: UITextFieldDelegate {
    
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

extension JourneyDetailsVC: ScreenNavigable {
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {}
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {}
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return nil
    }
}

extension JourneyDetailsVC: PaxPickerDelegate {
    
    func paxPicker(paxPicker: PaxPicker, didUpdateBarValue: Int) {
        let index = self.isOutboundTripScreen() == true ? 0 : 1
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
