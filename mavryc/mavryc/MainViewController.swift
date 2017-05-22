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
        self.updatePosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: center)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        // return map to optimal zoom state now that joystick was released...
        self.joystickMapCoordinator.reset()
    }
    
    /// 🕹🕹🕹
    func joystickTrackingHandler() -> ((CDJoystickData) -> Void)? {
        return { joystickData in
            //print("🕹 deltax:\(joystickData.velocity.x) deltay:\(joystickData.velocity.y)")
            
            let altitudeFloor = 70000.0 // 70k - shows about 3 airports in one scene at mesa/phoenix area
            let altitudeCeiling = 10000000.00 // 10mil - shows contiguous US in one scene
            
            self.updatePosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: joystickData.stickCenter)
            
            let deltaX = joystickData.velocity.x
            let deltaY = joystickData.velocity.y
            
            // 1. get map center
            let mapCenter = self.mapView!.centerCoordinate

            // 2. convert map coords to view coords so we can easily update with point values
            var targetPoint = self.mapView!.convert(mapCenter, toPointTo: self.view)

            // 3. update coord points with point additions
            targetPoint.x = targetPoint.x + (deltaX * 2)
            targetPoint.y = targetPoint.y + (deltaY * 2)
            // 4. convert view coords back into map coord
            let center:CLLocationCoordinate2D = self.mapView!.convert(targetPoint, toCoordinateFrom: self.view)
            
            // 5. create camera at new target center point, which we will now animate to from current location/altitude
            self.mapCam.centerCoordinate = center
            var altitude:CLLocationDistance = self.mapView!.camera.altitude // current altitude
            
            // 6. calculate altitude
            
            // 6a -- Analog Pixel-Altitude Algorithm
//            altitude = self.altitudeAnalogPixelToAltitudeAlgorithm(floor: altitudeFloor,
//                                                                   ceiling: altitudeCeiling,
//                                                                   currentAlt: self.mapView!.camera.altitude,
//                                                                   stickCenter: joystickData.stickCenter)
            
            // 6b -- psuedo-exponential growing altitude
            //altitude = self.altAlgTwo(absoluteDelta: max(abs(deltaX), abs(deltaY)))
            
            // 6c
            //altitude = CLLocationDistance(altitude + Double(self.altAlgOne(maxDelta: CGFloat(max(abs(deltaX), abs(deltaY))))))
            
            // 6d -- Exponential Curve based from min alt to max alt based on pixel x (min pixel to max pixel)
            altitude = self.altitudePixelToAltitudeExponentialFormula(floor: altitudeFloor,
                                                                               ceiling: altitudeCeiling,
                                                                               currentAlt: self.mapView!.camera.altitude,
                                                                               stickCenter: joystickData.stickCenter)
            
            self.mapCam.altitude = altitude
            print("currentAlt: \(self.mapView!.camera.altitude) --- targetAlt: \(self.mapCam.altitude)")
            
            // 7. instruct map to animate-transition to new camera
            self.mapView!.setCamera(self.mapCam, withDuration: 0, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        }
    }
    
    func altitudePixelToAltitudeExponentialFormula(floor: Double, ceiling: Double, currentAlt: CLLocationDistance, stickCenter: CGPoint) -> CLLocationDistance {
        // algorithm:
        // y = ab^x
        // model: y = floor * (pow(ceiling/floor, 1/pixelMax))^x
        let x = Double(max(abs(stickCenter.x), abs(stickCenter.y)))
        let pixelMax = Double(self.joystick.stickSize.width/2)
        let bRoot = pow(ceiling/floor, 1.0/pixelMax)
        let b = pow(bRoot, x)
        let y = floor * b
        
        return CLLocationDistance(y)
    }
    
    func altitudeAnalogPixelToAltitudeAlgorithm(floor: Double, ceiling: Double, currentAlt: CLLocationDistance, stickCenter: CGPoint) -> CLLocationDistance {
        // algorithm model: 
        // ((ceiling - floor) / maxJoystickCoverage) * actualPixelDistFromOrigin
        // ex: ((40mil - 70k) / 250) * number of pixels from origin.
        let distanceFromOriginPoint = max(abs(stickCenter.x), abs(stickCenter.y))
        let maxDistanceFromOrig = self.joystick.stickSize.width
        let altitudeSpread = ceiling - floor
        let proportionStep = CGFloat(altitudeSpread) / maxDistanceFromOrig
        print("distFromOriginPoint: \(distanceFromOriginPoint)")
        print("step amount \(proportionStep)")
        let alt = CLLocationDistance(proportionStep * distanceFromOriginPoint)
        print("analog pixel to alt. altitude: \(alt)")
        return alt
    }
    
    func altAlgOne(maxDelta: CGFloat) -> CGFloat {
        // alt = ((delta * 10) * 100) (^delta-1 if delta is > 1)
        let delta = maxDelta * 10
        var output = delta * 100
        if delta <= 2 {
            output = output * 10
        }
        if delta > 3 && delta < 5 {
            output = pow(output, 2)
        }
        if delta > 4 && delta < 8 {
            output = pow(output, 3)
        }
        return output
    }
    
    func altAlgTwo(absoluteDelta: CGFloat) -> Double {
        
        //            let movementX = ((deltaX * 10) / 0.1) / 10 // alg: ((.1 * 10) / .1) / 10 = 1 ... (() / .1) / 10 = 10
        //            let movementY = ((deltaY * 10) / 0.1) / 10 // ((delta * 10) / .1) / expFactor
        //            targetPoint.x = targetPoint.x + movementX
        //            targetPoint.y = targetPoint.y + movementY
        
//        self.joystickMapCoordinator.appendDelta(delta: absoluteDelta)
  //      print("absoluteDelta: \(absoluteDelta)")
    //    print("cumulative absoluteDelta: \(self.joystickMapCoordinator.cumulativeAbsoluteDelta)")
        
        let altitudeShift = Double(1000.0 * absoluteDelta)
        //print("altitude shift: \(altitudeShift)")
        return altitudeShift
    }
    
    // MARK: Joystick
    
    /// Keeps the disk/token image centered on the virtual joystick center
    private func updatePosition(for tokenView: UIView, toJoystick: UIView, atStickCenter: CGPoint) {
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

struct JoystickMapCoordinator {
    
    var vsyncCount = 0
    var lastPixelDistanceFromOrigin = 0.0
    
    init(lastPixelDistanceFromOrigin: CGFloat = 0.0, vsyncCount: Int = 0) {
        self.lastPixelDistanceFromOrigin = Double(lastPixelDistanceFromOrigin)
        self.vsyncCount = vsyncCount
    }
    
    mutating func reset() {
        self.lastPixelDistanceFromOrigin = 0.0
    }
    
    //var originPoint: Float
    //var latestPoint: Float
    
//    func isThresholdCrossed() {
//        
//    }
    
    
}
