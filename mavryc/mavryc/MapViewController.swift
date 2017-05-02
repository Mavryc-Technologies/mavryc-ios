//
//  MapViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/21/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    var receivedLocationCount = 0
    var isUpdatingLocation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.mapType = .satelliteFlyover
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        isUpdatingLocation = true
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

    // MARK:
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
            }
            isUpdatingLocation = false
        }
    }
    
    /// Log any errors to the console.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    // MARK: 
    // MARK: local search
    func performAirportSearch() {
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "airports"
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                print("Search error: \(String(describing: error))")
                return
            }
            
            print("number map items: \(response.mapItems.count)")
            for item in response.mapItems {
                print("🗺mapItem: \(item)")
                self.dropPin(placemark: item.placemark)
            }
            
            //let span = MKCoordinateSpanMake(1, 1)
            //let region = MKCoordinateRegionMake((response.mapItems.first?.placemark.coordinate)!, span)
            //self.mapView.setRegion(region, animated: true)
        }
    }
    
    func dropPin(placemark:MKPlacemark){
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
    }
}
