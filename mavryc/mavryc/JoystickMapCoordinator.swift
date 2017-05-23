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
    
    var panSpeedFactor: Double = 3.5 // tweaks the speed of joystick panning
    
    var isForceTouchMode: Bool {
        get {
            // :TODO: retrieve from userdefaults
            return false
        }
        set(value) {
            // :TODO: add to userdefaults
            
            if value {
                self.setupForceTouchMode()
            }
        }
    }
    
    // Moving Average local-stores
    private var movingAverageForceXs: [Double] = []
    private var movingAverageAltitudes: [Double] = []
    
    init(altitudeFloor: Double = 30000,
         altitudeCeiling: Double = 10000000,
         isForceTouchMode: Bool = false) {
        self.altitudeFloor = altitudeFloor
        self.altitudeCeiling = altitudeCeiling
        self.isForceTouchMode = isForceTouchMode
    }
    
    // MARK: - Map Position
    
    /// Calculate next position of the map based on joystick and current map position
    func nextMapCenterPosition(mapView: MGLMapView, mapParentView: UIView, joystickDelta: CGPoint) -> CLLocationCoordinate2D {
        
        let deltaX = joystickDelta.x
        let deltaY = joystickDelta.y
        
        let currentMapCenter = mapView.centerCoordinate
        
        // convert map coords to view coords so we can easily update with point values
        var targetPoint = mapView.convert(currentMapCenter, toPointTo: mapParentView)
        
        let velocity = CGFloat(self.panSpeedFactor)
        // update coord points with point additions + a velocity factor for appropriate pan-speed effect
        targetPoint.x = targetPoint.x + (deltaX * velocity)
        targetPoint.y = targetPoint.y + (deltaY * velocity)
        
        // convert view coords back into map coord
        let center:CLLocationCoordinate2D = mapView.convert(targetPoint, toCoordinateFrom: mapParentView)
        return center
    }
    
    // MARK: - Map Altitude
    
    /// Calculate altitude with pixel and force touch data
    func altitudeForForceTouch(joystick: CDJoystick, stickCenter: CGPoint, force: CGFloat) -> CLLocationDistance {
        
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
    
    /// Calculate Altitude from Exponential formula based on pixel position & additional moving-average smoothing
    /// algorithm: y = ab^x
    /// applied: y = floor * (pow(ceiling/floor, 1/pixelMax))^x
    func altitudeForPixelExponentialAndMAASmoothing(joystick: CDJoystick,
                                     stickCenter: CGPoint) -> CLLocationDistance {
        
        let x = Double(max(abs(stickCenter.x), abs(stickCenter.y)))
        let pixelMax = Double(joystick.stickSize.width/2)
        let bRoot = pow(self.altitudeCeiling/self.altitudeFloor, 1.0/pixelMax)
        let b = pow(bRoot, x)
        var y = self.altitudeFloor * b
        
        y = self.nextMovingAverageForAltitude(altitude: y)
        
        return CLLocationDistance(y) // altitude in meters mapped exponentially to the max x/y distance of the joystick from center
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
        let alt = CLLocationDistance(proportionStep * distanceFromOriginPoint)
        return alt
    }
    
    // MARK: - Support
    
    // calculates next force touch value based on a moving average using latest force touch value with a list of last n number of recorded force touches.
    func calculateNextXFromMovingAverageForces(x: Double) -> Double {
        let period = 120 // touch events come in at 60 per sec, therefore this smooths across more time for more pleasant effect
        if self.movingAverageForceXs.count > period {
            self.movingAverageForceXs.remove(at: 0)
        }
        self.movingAverageForceXs.append(x)
        let sum: Double = self.movingAverageForceXs.reduce(0, +)
        let avg: Double = sum/Double(self.movingAverageForceXs.count)
        //print("sum:\(sum) avg:\(avg)")
        return avg
    }
    
    func nextMovingAverageForAltitude(altitude: Double) -> Double {
        let period = 120 // about 2 seconds worth of touch events
        if self.movingAverageAltitudes.count > period {
            self.movingAverageAltitudes.remove(at: 0)
        }
        self.movingAverageAltitudes.append(altitude)
        let sum: Double = self.movingAverageAltitudes.reduce(0, +)
        let avg: Double = sum/Double(self.movingAverageAltitudes.count)
        return avg
    }
    
    // MARK: - Force Touch Mode
    private func setupForceTouchMode() {
        
        for _ in 0...120 {
            // initializes force touch moving average list at force of 5.0 (which is about the force required to hover at the starting altitude)
            self.movingAverageForceXs.append(5.0)
        }
        
        self.panSpeedFactor = 5.0
    }
}
