//
//  JoystickController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/17/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import Mapbox

class JoystickController: NSObject {
    
    fileprivate weak var container: UIViewController!
    fileprivate weak var mapView: MGLMapView!
    fileprivate weak var joystick: CDJoystick!
    fileprivate weak var joystickToken: UIView!
    
    fileprivate var joystickMapCoordinator = JoystickMapCoordinator()
    fileprivate var mapCam: MGLMapCamera = MGLMapCamera()
    
    required init(joystick: CDJoystick,
                  joystickToken: UIView,
                  container: UIViewController,
                  mapView: MGLMapView) {

        super.init()
        self.joystick = joystick
        self.joystickToken = joystickToken
        self.container = container
        self.mapView = mapView
     
        // TODO: feature flag here: 
        let joystickMapInteractionEnabled = FeatureFlag.joystickTrackedMapInteraction.isFeatureEnabled()
        
        if joystickMapInteractionEnabled {
            self.joystickToken.isUserInteractionEnabled = !joystickMapInteractionEnabled
            self.joystick.delegate = self
            self.joystick.trackingHandler = self.joystickTrackingHandler()
        }
    }
}

// MARK: - JoyStick Delegate
extension JoystickController: JoystickDelegate {
    
    func stickDidResetTo(center: CGPoint) {
        self.updateDiskPosition(for: self.joystickToken,
                                toJoystick: self.joystick,
                                atStickCenter: center)
        
        UIView.animate(withDuration: 0.25) {
            self.container.view.layoutIfNeeded()
        }
    }
    
    /// 🕹🕹🕹
    func joystickTrackingHandler() -> ((CDJoystickData) -> Void)? {
        return { joystickData in
            
            // Joystick Modes: stationary-disk or moving-disk. Comment in below for moving disk.
            self.updateDiskPosition(for: self.joystickToken, toJoystick: self.joystick, atStickCenter: joystickData.stickCenter)
            
            // Map's position
            let nextCenter = self.joystickMapCoordinator.nextMapCenterPosition(mapView: self.mapView!, mapParentView: self.container.view, joystickDelta: joystickData.velocity)
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



