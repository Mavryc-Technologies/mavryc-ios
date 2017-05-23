//
//  JoystickMapCoordinator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/22/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import MapKit
import Mapbox

class JoystickMapCoordinator {
    
    var altitudeFloor: Double = 0.0 // @ 70k - shows about 3 airports in one scene at mesa/phoenix area
    var altitudeCeiling: Double = 0.0 // 10mil - shows contiguous US in one scene
    
    var movingAverageForceXs: [Double] = []
    
    init(altitudeFloor: Double = 30000, altitudeCeiling: Double = 10000000) {
        self.altitudeFloor = altitudeFloor
        self.altitudeCeiling = altitudeCeiling

        // force touch
        // initializes force touch moving average list at force of 5.0 (which is about the force required to hover at the starting altitude)
        for _ in 0...120 {
            self.movingAverageForceXs.append(5.0)
        }
    }
    
    // MARK: - Map Position
    
    /// Calculate next position of the map based on joystick and current map position
    func nextMapCenterPosition(mapView: MGLMapView, mapParentView: UIView, joystickDelta: CGPoint) -> CLLocationCoordinate2D {
        
        let velocityFactor: CGFloat = 5.0
        
        let deltaX = joystickDelta.x
        let deltaY = joystickDelta.y
        
        let currentMapCenter = mapView.centerCoordinate
        
        // convert map coords to view coords so we can easily update with point values
        var targetPoint = mapView.convert(currentMapCenter, toPointTo: mapParentView)
        
        // update coord points with point additions + a movement/speed factor
        targetPoint.x = targetPoint.x + (deltaX * velocityFactor)
        targetPoint.y = targetPoint.y + (deltaY * velocityFactor)
        
        // convert view coords back into map coord
        let center:CLLocationCoordinate2D = mapView.convert(targetPoint, toCoordinateFrom: mapParentView)
        return center
    }
    
    // MARK: - Map Altitude
    
    /// Calculate altitude with pixel and force touch data
    func altitudeForPixelAndForce(joystick: CDJoystick, stickCenter: CGPoint, force: CGFloat) -> CLLocationDistance {
        
        print("force: \(force)")
        
        // invert x so we zoom-in (decrease altitude) as force increases
        let forceMax = Double(6.666)
        var x = Double(forceMax - Double(force))
        
        // moving average on x
        x = self.calculateNextXFromMovingAverageForces(x: x)
        
        let bRoot = pow(self.altitudeCeiling/self.altitudeFloor, 1.0/forceMax)
        let b = pow(bRoot, x)
        let y = self.altitudeFloor * b
        return CLLocationDistance(y) // altitude in meters exponential derived from F(x)=ab^x where x is touch-force between 0 and 1, y is altitude
    }
    
    /// Calculate Altitude from Exponential formula based on pixel position
    /// algorithm: y = ab^x
    /// applied: y = floor * (pow(ceiling/floor, 1/pixelMax))^x
    func altitudeForPixelExponential(joystick: CDJoystick,
                                    stickCenter: CGPoint) -> CLLocationDistance {
        
        let x = Double(max(abs(stickCenter.x), abs(stickCenter.y)))
        let pixelMax = Double(joystick.stickSize.width/2)
        let bRoot = pow(self.altitudeCeiling/self.altitudeFloor, 1.0/pixelMax)
        let b = pow(bRoot, x)
        let y = self.altitudeFloor * b
        return CLLocationDistance(y) // altitude in meters mapped exponentially to the max x/y distance of the joystick from center
    }
    
    /// Calculate Altitude from Linear formula based on pixel position
    /// algorithm: avg altitude incremental * pixel position
    /// applied: ((ceiling - floor) / maxJoystickCoverage) * actualPixelDistFromOrigin
    /// example: ((40mil - 70k) / 250) * number of pixels from origin.
    func altitudeForPixelLinear(floor: Double,
                               ceiling: Double,
                               currentAlt: CLLocationDistance,
                               stickCenter: CGPoint,
                               joystick: CDJoystick) -> CLLocationDistance {
        
        let distanceFromOriginPoint = max(abs(stickCenter.x), abs(stickCenter.y))
        let maxDistanceFromOrig = joystick.stickSize.width
        let altitudeSpread = ceiling - floor
        let proportionStep = CGFloat(altitudeSpread) / maxDistanceFromOrig
        print("distFromOriginPoint: \(distanceFromOriginPoint)")
        print("step amount \(proportionStep)")
        let alt = CLLocationDistance(proportionStep * distanceFromOriginPoint)
        print("analog pixel to alt. altitude: \(alt)")
        return alt
    }
    
    // Support
    
    func calculateNextXFromMovingAverageForces(x: Double) -> Double {
        let period = 120 // touch events come in at 60 per sec, therefore this smooths across more time for more pleasant effect
        if self.movingAverageForceXs.count > period {
            self.movingAverageForceXs.remove(at: 0)
        }
        self.movingAverageForceXs.append(x)
        let sum: Double = self.movingAverageForceXs.reduce(0, +)
        let avg: Double = sum/Double(self.movingAverageForceXs.count)
        print("sum:\(sum) avg:\(avg)")
        return avg
    }
}
