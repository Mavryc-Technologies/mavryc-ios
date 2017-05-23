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

    @IBOutlet weak var navBar: UINavigationBar! {
        didSet {
            navBar.setBackgroundImage(UIImage(named: "Header.png"),
                                      for: .default)
        }
    }
    @IBOutlet weak var panelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var joystick: CDJoystick!
    @IBOutlet weak var joystickToken: UIView!
    @IBOutlet weak var joystickTokenDisk: UIImageView!
    
    // Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    var receivedLocationCount = 0
    var isUpdatingLocation = false
    
    // Map
    var mapView: MGLMapView? = nil
    var mapCam: MGLMapCamera = MGLMapCamera()
    
    // Joystick & Map
    var joystickMapCoordinator = JoystickMapCoordinator()
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: fix displacement of the joystickToken on varying size screens
        
        joystick.delegate = self
        joystick.trackingHandler = self.joystickTrackingHandler()
        
        //mapView.mapType = .satelliteFlyover
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        isUpdatingLocation = true
    }

    // MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JourneyPanelSegue" {
            let panel = segue.destination as? FlightPanelViewController
            panel?.delegate = self
        }
        if segue.identifier == "MapboxSegue" {
            let vc = segue.destination
            self.mapView = vc.view as! MGLMapView
        }
    }
}

// MARK: - Location Manager Delegate
extension MainViewController: CLLocationManagerDelegate {
    
    // MARK: Location Delegation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        receivedLocationCount = receivedLocationCount + locations.count
        reverseGeocodeLocation(locations: locations)
        print("number of received locations: \(receivedLocationCount)")
        print("locations: \(locations)")
        if receivedLocationCount > 3 {
            manager.stopUpdatingLocation()
            
            if isUpdatingLocation {

                performAirportSearch()
                mapView?.setCenter(CLLocationCoordinate2D(latitude: locations.first!.coordinate.latitude,
                                                         longitude: locations.first!.coordinate.longitude),
                                  zoomLevel: 12, animated: true)
            }
            isUpdatingLocation = false
        }
    }
    
    /// Log any errors to the console.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    func reverseGeocodeLocation(locations: [CLLocation]) {
        locations.forEach { (loc) in
            CLGeocoder().reverseGeocodeLocation(loc) { placemarks, error in
                print("reverseGeocodeLocation: \(loc)")
                print("placemarks: \(String(describing: placemarks?.debugDescription))")
                placemarks?.forEach({ (placemark) in
                    print("🐸--- placemark: \(placemark)")
                })
            }
        }
    }
    
    // MARK: local search
    func performAirportSearch() {
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = "airports"
//        request.region = mapView.region
//        
//        let search = MKLocalSearch(request: request)
//        search.start { (response, error) in
//            guard let response = response else {
//                print("Search error: \(String(describing: error))")
//                return
//            }
//            
//            print("number map items: \(response.mapItems.count)")
//            for item in response.mapItems {
//                print("🗺mapItem: \(item)")
//                self.dropPin(placemark: item.placemark)
//            }
        
            //let span = MKCoordinateSpanMake(1, 1)
            //let region = MKCoordinateRegionMake((response.mapItems.first?.placemark.coordinate)!, span)
            //self.mapView.setRegion(region, animated: true)
//        }
    }
    
    func dropPin(placemark:MKPlacemark){
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = placemark.coordinate
//        annotation.title = placemark.name
//        if let city = placemark.locality,
//            let state = placemark.administrativeArea {
//            annotation.subtitle = "\(city) \(state)"
//        }
//        mapView.addAnnotation(annotation)
    }
}

// MARK: - JoyStick Delegate
extension MainViewController: JoystickDelegate {
    
    func stickDidResetTo(center: CGPoint) {
        
        self.updateDiskPosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: center)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        // return map to optimal zoom state now that joystick was released...
        // self.joystickMapCoordinator.reset()
    }
    
    /// 🕹🕹🕹
    func joystickTrackingHandler() -> ((CDJoystickData) -> Void)? {
        return { joystickData in
            
            // Joystick Modes: stationary-disk or moving-disk. Comment in below for moving disk.
            //self.updateDiskPosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: joystickData.stickCenter)
            
            // Map's position
            let nextCenter = self.joystickMapCoordinator.nextMapCenterPosition(mapView: self.mapView!, mapParentView: self.view, joystickDelta: joystickData.velocity)
            self.mapCam.centerCoordinate = nextCenter
            
            // Map's altitude
            //let nextAltitude = self.joystickMapCoordinator.altitudeForPixelExponential(joystick: self.joystick, stickCenter: joystickData.stickCenter)
            let nextAltitude = self.joystickMapCoordinator.altitudeForPixelAndForce(joystick: self.joystick, stickCenter: joystickData.stickCenter, force: joystickData.force)
            self.mapCam.altitude = nextAltitude
            
            // Map's viewing angle
            self.mapCam.pitch = 0.5
            
            self.mapView!.setCamera(self.mapCam, withDuration: 0, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    // MARK: Joystick
    
    /// Keeps the disk/token image centered on the virtual joystick center
    private func updateDiskPosition(for tokenView: UIView, toJoystick: UIView, atStickCenter: CGPoint) {
        let centerX = ((toJoystick.center.x + atStickCenter.x) - (joystickTokenDisk.frame.width/8))
        let centerY = ((toJoystick.center.y + atStickCenter.y) - (joystickTokenDisk.frame.height/8))
        tokenView.center = CGPoint(x: centerX, y: centerY )
    }
}

// MARK: - Panel Delegate
extension MainViewController: PanelDelegate {
    
    func panelDidOpen() {
        SafeLog.print("panel opened")
    }
    
    func panelDidClose() {
        SafeLog.print("panel closed")
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
