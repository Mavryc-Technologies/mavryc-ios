//
//  LocationController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/16/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import CoreLocation

class LocationController: NSObject {

    // Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    var receivedLocationCount = 0
    var isUpdatingLocation = false
    static var lastKnownUserLocation: CLLocation?
    
    public func requestUserLocation(completion: ((CLLocation) -> Void)?) {
        self.locationReturnedCompletion = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        isUpdatingLocation = true
    }
    
    /// cache the completion to use upon request's success in delegate below
    fileprivate var locationReturnedCompletion: ((CLLocation) -> Void)?
}

// MARK: - Location Manager Delegate
extension LocationController: CLLocationManagerDelegate {
    
    // MARK: Location Delegation
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        receivedLocationCount = receivedLocationCount + locations.count
        if receivedLocationCount > 3 {
            
            manager.stopUpdatingLocation()
            
            if isUpdatingLocation {
                if let userLocation = locations.first {
                    LocationController.lastKnownUserLocation = userLocation
                    self.locationReturnedCompletion?(userLocation)
                }
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
    
    // MARK: - Map Annotation Support
    func updateUserLocation(location: CLLocation) {
        
        // put map center at user location
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        //mapView?.setCenter(center, zoomLevel: 12, animated: true)
        
        // Fill an array with point annotations and add it to the map.
//        let userAnnotation = CustomPointAnnotation()
//        userAnnotation.coordinate = center
//        userAnnotation.willUseImage = true
        //mapView?.addAnnotation(userAnnotation)
    }

    
}
