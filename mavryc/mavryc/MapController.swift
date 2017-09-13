//
//  MapController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/16/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import Mapbox

class MapController: NSObject {
    
    fileprivate weak var mapView: MGLMapView!
    fileprivate weak var locationController: LocationController!
    
    var mapCam: MGLMapCamera = MGLMapCamera()
    
    required init(locationController: LocationController, mapView: MGLMapView) {
        super.init()
        self.mapView = mapView
        self.locationController = locationController
        
        self.mapView.delegate = self
        self.locationController.requestUserLocation { [weak self] (location) in
            self?.updateUserLocation(location: location)
        }
    }
    
    /// Animate map center toward a new given location at a given interval
    public func animateMap(to location: CLLocation, map: MGLMapView, duration: TimeInterval) {
        self.mapCam.centerCoordinate = location.coordinate
        self.mapCam.altitude = Double(3000000)
        self.mapCam.pitch = 60.0
        map.setCamera(self.mapCam, withDuration: duration, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
    }
    
    /// Visually update the given user location on the map
    func updateUserLocation(location: CLLocation) {
        
        // put map center at user location
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        mapView?.setCenter(center, zoomLevel: 12, animated: true)
        self.mapCam.centerCoordinate = location.coordinate
        self.mapCam.altitude = Double(500000)
        self.mapCam.pitch = 30.0
        mapView?.setCamera(self.mapCam, withDuration: 0.5, animationTimingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn))
        
        // Fill an array with point annotations and add it to the map.
        let userAnnotation = CustomPointAnnotation()
        userAnnotation.coordinate = center
        userAnnotation.willUseImage = true
        mapView?.addAnnotation(userAnnotation)
    }
    
    /// Fetch all airport locations and render to the map.
    /// Alternative to this is the map marker style approach.
    private func addAirportAnnotations(to mapView: MGLMapView) {
        
        Airports.requestAirports { (locations) in
            var annotations = [CustomPointAnnotation]()
            locations.forEach({ (loc) in
                let point = CustomPointAnnotation()
                point.coordinate = loc.location.coordinate
                point.title = loc.threeLetterCode
                point.subtitle = loc.airportName
                point.showAirport = true
                point.willUseImage = true
                annotations.append(point)
            })
            DispatchQueue.main.async {
                mapView.addAnnotations(annotations)
            }
        }
    }
    
    private func addClusteredAirportMarkers() {}
}

// MARK: - MapView Delegate
extension MapController: MGLMapViewDelegate {
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // TODO: comment in code below to show and work on refinement of mapbox's polyline. However, better than this would be implement our own arc core graphics line above the map layer. There are many limitations with the mapbox polyline.
        //self.joystickMapCoordinator.addPolylineLayer(to: style)
        
        // add airports to map
        //self.addAirportAnnotations(to: mapView)
    }
    
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        if let castAnnotation = annotation as? CustomPointAnnotation {
            if (castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if annotationView == nil {
            annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
            annotationView!.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            let hue = CGFloat(annotation.coordinate.longitude) / 100
            annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        
        var isAirport = false
        if let castAnnotation = annotation as? CustomPointAnnotation {
            isAirport = castAnnotation.showAirport
            if (!castAnnotation.willUseImage) {
                return nil;
            }
        }
        
        if isAirport {
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "airportMarker")
            if annotationImage == nil {
                var image = UIImage(named: "Depart Icon")!
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "airportMarker")
                
            }
            return annotationImage
            
        } else { // is user location
            var annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: "userLocationMaker")
            if annotationImage == nil {
                var image = UIImage(named: "LocationMarker")!
                image = image.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 0, bottom: image.size.height/2, right: 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "userLocationMaker")
            }
            return annotationImage
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
}

// MARK: - MGLPointAnnotation subclass
class CustomPointAnnotation: MGLPointAnnotation {
    var willUseImage: Bool = false
    var showAirport: Bool = false
}

// MARK: - MGLAnnotationView subclass
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
