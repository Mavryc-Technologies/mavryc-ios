//
//  MainViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

class MainViewController: UIViewController {

    // Nav Bar
    @IBOutlet weak var navBar: UINavigationBar! {
        didSet {
            navBar.setBackgroundImage(UIImage(named: "Header.png"),
                                      for: .default)
        }
    }
    
    @IBOutlet weak var navLeftButtonHamburgerAndBack: UIBarButtonItem! {
        didSet {
            navLeftButtonHamburgerAndBack.image = UIImage(named: "Hamburger.png")
        }
    }
    
    @IBOutlet weak var panelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var destinationSearchButton: UIView!
    @IBOutlet weak var destinationSearchTextField: UITextField!
    
    // Joystick & Map
    @IBOutlet weak var joystick: CDJoystick!
    @IBOutlet weak var joystickToken: UIView!
    var joystickController: JoystickController?
    
    // Map
    var mapView: MGLMapView?
    
    var mapController: MapController?
    var locationController = LocationController()
    
    // Panel
    weak var panel: FlightPanelViewController?
    
    var hamburgerNavMode = true
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mapView = mapView {
            mapController = MapController(locationController: locationController, mapView: mapView)
            joystickController = JoystickController(joystick: joystick, joystickToken: joystickToken, container: self, mapView: mapView)
        }
    }
    
    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JourneyPanelSegue" {
            let panel = segue.destination as? FlightPanelViewController
            panel?.delegate = self
            self.panel = panel
        }
        if segue.identifier == "MapboxSegue" {
            let vc = segue.destination
            self.mapView = (vc.view as! MGLMapView)
        }
    }
    
    // MARK: - Interface Actions
    @IBAction func destinationSearchButtonAction(_ sender: Any) {
        ScreenNavigator.destinationSearchButtonWasPressedState = true
        self.panel?.triggerPanel(shouldOpen: true)
    }
    
    @IBAction func joystickTapAction(_ sender: UITapGestureRecognizer) {
        if let userLocation = LocationController.lastKnownUserLocation, let map = self.mapView {
            self.mapController?.animateMap(to: userLocation, map: map, duration: 2)
        }
    }
    
    // MARK: - Screen Navigation
    
    @IBAction func navButtonAction(_ sender: Any) {
        if self.hamburgerNavMode {
            // TODO: implement hamburger menu trigger
        } else {
            // back nav mode
            NotificationCenter.default.post(name: Notification.Name.PanelScreen.DidTapBackNav, object: self, userInfo:nil)
        }
    }
    
    func showHamburgerNav() {
        self.hamburgerNavMode = true
        self.navLeftButtonHamburgerAndBack.image = UIImage(named: "Hamburger.png")
    }
    
    func showBackButtonNav() {
        self.hamburgerNavMode = false
        self.navLeftButtonHamburgerAndBack.image = UIImage(named: "BackArrow.png")
    }
}


// MARK: - Panel Delegate
extension MainViewController: PanelDelegate {
    
    func panelDidOpen() {
        SafeLog.print("panel opened")
        self.showBackButtonNav()
    }
    
    func panelWillClose() {
        if let arrivalCity = TripCoordinator.sharedInstance.currentTripInPlanning?.flights[0].arrivalString {
            destinationSearchTextField.text = arrivalCity
        }
        if destinationSearchTextField.text != "Where To?" {
            destinationSearchButton.isHidden = true
        } else {
            destinationSearchButton.isHidden = false
        }
    }
    
    func panelDidClose() {
        SafeLog.print("panel closed")
        self.showHamburgerNav()
    }
    
    func panelExtendedHeight() -> CGFloat {
        return self.view.frame.height - 64 // 64 is the nav bar height + the status bar height
    }
    
    func panelRetractedHeight() -> CGFloat {
        return 58 // arbitrary staring point for the pull up view that looks good
    }
    
    func panelLayoutConstraintToUpdate() -> NSLayoutConstraint {
        return self.panelHeightConstraint
    }
    
    func panelParentView() -> UIView {
        return self.view
    }
}
