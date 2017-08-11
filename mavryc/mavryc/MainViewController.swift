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
    var joystickController: JoystickController?
    @IBOutlet weak var joystick: CDJoystick!
    @IBOutlet weak var joystickToken: UIView! {
        didSet {
            joystickToken.center =  joystick.center
        }
    }
    
    // Map
    var mapView: MGLMapView?
    
    var mapController: MapController?
    var locationController = LocationController()
    
    // Panel
    weak var panel: FlightPanelViewController?
    
    var isSlideOutMenuVisible = false
    var slideoutMenuViewController: UIViewController? = nil
    var slideOutMenuPresentingViewController: UIViewController? = nil
    var hamburgerNavMode = true
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mapView = mapView {
            mapController = MapController(locationController: locationController, mapView: mapView)
            joystickController = JoystickController(joystick: joystick, joystickToken: joystickToken, container: self, mapView: mapView)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(slideoutMenuCloseWasTapped),
                                               name: Notification.Name.SlideoutMenu.CloseWasTapped,
                                               object: nil)
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
            self.triggerHamburgerMenu()
        } else {
            // back nav mode
            ScreenNavigator.sharedInstance.navigateBackward()
        }
    }
    
    func showHamburgerNav() {
        self.hamburgerNavMode = true
        self.navLeftButtonHamburgerAndBack.image = UIImage(named: "Hamburger.png")
    }
    
    @objc private func slideoutMenuCloseWasTapped(notification: NSNotification) {
        self.triggerHamburgerMenu()
    }
    
    func triggerHamburgerMenu() {
        
        if isSlideOutMenuVisible {
            self.dismissSlideOutMenu()
        } else {
            self.presentSlideOutMenu(animated: true)
        }
        
        isSlideOutMenuVisible = !isSlideOutMenuVisible
    }
    
    func presentSlideOutMenu(animated: Bool) {
        // make it visible
        if let visibleViewCtrl = UIApplication.shared.keyWindow?.visibleViewController {
            let sb = UIStoryboard.init(name: "SlideoutMenu", bundle: Bundle.main)
            if let vc = sb.instantiateInitialViewController() {
                self.slideoutMenuViewController = vc
                self.slideOutMenuPresentingViewController = visibleViewCtrl
                
                var offScreenFrame = vc.view.frame
                let onScreenFrame = vc.view.frame
                offScreenFrame.origin.x = (vc.view.frame.width * -1) - 1
                vc.view.frame = offScreenFrame
                
                visibleViewCtrl.view.addSubview(vc.view)
                UIApplication.shared.isStatusBarHidden = true
                
                UIView.animate(withDuration: 0.3, animations: {
                    vc.view.frame = onScreenFrame
                    vc.view.layoutIfNeeded()
                    self.view.layoutIfNeeded()
                }, completion: { (done) in
                    // nothing for now
                })
                
                
            } else {
                print("sad - it didn't work😫")
            }
        }
    }
    
    func dismissSlideOutMenu() {
        // make it go away
        if let vc = self.slideoutMenuViewController, let _ = slideOutMenuPresentingViewController {
            
            var offScreenFrame = vc.view.frame
            offScreenFrame.origin.x = (vc.view.frame.width * -1) - 1
            
            UIView.animate(withDuration: 0.3, animations: { 
                vc.view.frame = offScreenFrame
                vc.view.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }, completion: { (done) in
                vc.view.removeFromSuperview()
                self.slideoutMenuViewController = nil
                UIApplication.shared.isStatusBarHidden = false
            })
        }
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
