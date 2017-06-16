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
    
    // Joystick & Map
    @IBOutlet weak var joystick: CDJoystick!
    @IBOutlet weak var joystickToken: UIView!
    @IBOutlet weak var joystickTokenDisk: UIImageView!
    var joystickMapCoordinator = JoystickMapCoordinator()
    
    // Map
    var mapView: MGLMapView?
    var mapCam: MGLMapCamera = MGLMapCamera()
    
    var mapController: MapController?
    var locationController = LocationController()
    
    // Panel
    weak var panel: FlightPanelViewController?
    
    var hamburgerNavMode = true
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: add feature flagging for joystick
        //joystick.delegate = self
        //joystick.trackingHandler = self.joystickTrackingHandler()
        
        if let mapView = mapView {
            mapController = MapController(locationController: locationController, mapView: mapView)
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
    @IBAction func distinationSearchButtonAction(_ sender: Any) {
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

// MARK: - JoyStick Delegate
extension MainViewController: JoystickDelegate {
    
    func stickDidResetTo(center: CGPoint) {
        self.updateDiskPosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: center)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 🕹🕹🕹
    func joystickTrackingHandler() -> ((CDJoystickData) -> Void)? {
        return { joystickData in
            
            // Joystick Modes: stationary-disk or moving-disk. Comment in below for moving disk.
            self.updateDiskPosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: joystickData.stickCenter)
            
            // Map's position
            let nextCenter = self.joystickMapCoordinator.nextMapCenterPosition(mapView: self.mapView!, mapParentView: self.view, joystickDelta: joystickData.velocity)
            self.mapCam.centerCoordinate = nextCenter
            
            // Add/Update curved Polyline (polyline test code)
//            let LAX = CLLocation(latitude: 33.9424955, longitude: -118.4080684)
//            let JFK = CLLocation(latitude: self.mapCam.centerCoordinate.latitude, longitude: self.mapCam.centerCoordinate.longitude)
//            var coordinates = [LAX.coordinate, JFK.coordinate]
//            self.joystickMapCoordinator.updatePolylineWithCoordinates(coordinates: coordinates)
            
            // Map's altitude
            var nextAltitude: CLLocationDistance = 0.0
            if self.joystickMapCoordinator.isForceTouchMode {
                nextAltitude = self.joystickMapCoordinator.altitudeForForceTouch(joystick: self.joystick, stickCenter: joystickData.stickCenter, force: joystickData.force)
            } else {
                //nextAltitude = self.joystickMapCoordinator.altitudeForPixelExponential(joystick: self.joystick, stickCenter: joystickData.stickCenter)
                
                nextAltitude = self.joystickMapCoordinator.altitudeForPixelExponentialAndMAASmoothing(joystick: self.joystick, stickCenter: joystickData.stickCenter)
            }
            self.mapCam.altitude = nextAltitude
            
            // Map's viewing pitch
            //self.mapCam.pitch = 60.0
            
            self.mapView!.setCamera(self.mapCam, withDuration: 0, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    // MARK: Joystick
    
    /// Keeps the disk/token image centered on the virtual joystick center
    private func updateDiskPosition(for tokenView: UIView, toJoystick: UIView, atStickCenter: CGPoint) {
        let centerX = ((toJoystick.frame.origin.x + atStickCenter.x))
        let centerY = ((toJoystick.frame.origin.y + atStickCenter.y))
        tokenView.center = CGPoint(x: centerX, y: centerY )
    }
    
    
    /* TODO: Consider the following:
     - implement dead zone (of perhaps 10-20 pixels) at center of joystickTokenDisk
     - center the joystick/deadzone on initial touch from initial touch point; ie., don't jump the stick to initial touch point.
     - reset joystick and animate/transition appropriately on release of stick
     - fly to certain view of flight leg once destination is set/selected
     - implement arced/curved polyline or core graphics curved line extending from origin out and above map across and to destination
     - implement modes and a dev menu for playing with modes: Stationary-disk On/Off, gyro-compass-directed-map On/Off, force-touch On/Off, Joystick On/Off ...
     - gyro-compass directed mode would use gyro and compass to interact with map; the user to see flat map will hold the phone flat, the compass orientation will orient the map according to the current compass heading; bringing the phone in more of a vertical position will tilt the map accordingly. The experience would be akin to the interaction you might have in an actual room with a map in real life.
     */
}


// MARK: - Panel Delegate
extension MainViewController: PanelDelegate {
    
    func panelDidOpen() {
        SafeLog.print("panel opened")
        self.showBackButtonNav()
    }
    
    func panelDidClose() {
        SafeLog.print("panel closed")
        self.showHamburgerNav()
    }
    
    func panelExtendedHeight() -> CGFloat {
        return self.view.frame.height - 64 // 64 is the nav bar height + the status bar height
    }
    
    func panelRetractedHeight() -> CGFloat {
        return 60 // arbitrary staring point for the pull up view that looks good
    }
    
    func panelLayoutConstraintToUpdate() -> NSLayoutConstraint {
        return self.panelHeightConstraint
    }
    
    func panelParentView() -> UIView {
        return self.view
    }
}
