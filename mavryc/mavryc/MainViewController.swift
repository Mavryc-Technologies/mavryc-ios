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
    
    @IBOutlet weak var destinationSearchButton: UIView!
    
    // Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    var receivedLocationCount = 0
    var isUpdatingLocation = false
    
    // Map
    var mapView: MGLMapView? = nil
    var mapCam: MGLMapCamera = MGLMapCamera()
    
    // Joystick & Map
    var joystickMapCoordinator = JoystickMapCoordinator()
    
    // Panel
    weak var panel: FlightPanelViewController? = nil
    
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
        
        self.mapView!.delegate = self
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
    
    // MARK: Interface Actions
    @IBAction func distinationSearchButtonAction(_ sender: Any) {
        self.panel?.openPanelAndSetState()
    }
}

// MARK: - Location Manager Delegate
extension MainViewController: CLLocationManagerDelegate {
    
    // MARK: Location Delegation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        receivedLocationCount = receivedLocationCount + locations.count
        //reverseGeocodeLocation(locations: locations)
//        print("number of received locations: \(receivedLocationCount)")
//        print("locations: \(locations)")
        if receivedLocationCount > 3 {
            
            manager.stopUpdatingLocation()
            
            if isUpdatingLocation {
                guard let lat = locations.first?.coordinate.latitude else { return }
                guard let lon = locations.first?.coordinate.longitude else { return }
                let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                mapView?.setCenter(center, zoomLevel: 12, animated: true)
                
                // Fill an array with point annotations and add it to the map.
                let userAnnotation = MGLPointAnnotation()
                userAnnotation.coordinate = center
                mapView?.addAnnotation(userAnnotation)
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
                placemarks?.forEach({ (placemark) in
                    print("🐸--- placemark: \(placemark)")
                })
            }
        }
    }
    
}


// MARK: - MapView Delegate
extension MainViewController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
    
        // TODO: comment in code below to show and work on refinement of mapbox's polyline. However, better than this would be implement our own arc core graphics line above the map layer. There are many limitations with the mapbox polyline.
        self.joystickMapCoordinator.addPolylineLayer(to: style)
    }
    
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        // This example is only concerned with point annotations.
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        // Use the point annotation’s longitude value (as a string) as the reuse identifier for its view.
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // If there’s no reusable annotation view available, initialize a new one.
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            // Set the annotation view’s background color to a value determined by its longitude.
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

//
// MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Use CALayer’s corner radius to turn this view into a circle.
        layer.cornerRadius = frame.width / 2
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Animate the border width in/out, creating an iris effect.
        let animation = CABasicAnimation(keyPath: "borderWidth")
        animation.duration = 0.1
        layer.borderWidth = selected ? frame.width / 4 : 2
        layer.add(animation, forKey: "borderWidth")
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
