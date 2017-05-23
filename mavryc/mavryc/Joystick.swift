//
//  Joystick.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/9/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//
// Based On:
//
//  CDJoystick.swift
//  CDJoystick
//  Created by Cole Dunsby on 2015-12-21.
//

import UIKit

public struct CDJoystickData: CustomStringConvertible {
    
    /// The Force!
    public var force: CGFloat = 0.0
    
    /// (-1.0, -1.0) at bottom left to (1.0, 1.0) at top right
    public var velocity: CGPoint = .zero
    
    /// 0 at top middle to 6.28 radians going around clockwise
    public var angle: CGFloat = 0.0
    
    public var stickCenter: CGPoint = .zero
    
    public var description: String {
        return "velocity: \(velocity), angle: \(angle)"
    }
}

public protocol JoystickDelegate {
    
    /// let delegate know the position of the joystick has been reset
    func stickDidResetTo(center:CGPoint)
}

@IBDesignable
public class CDJoystick: UIView {
    
    @IBInspectable public var substrateColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var substrateBorderColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) { didSet { setNeedsDisplay() }}
    @IBInspectable public var substrateBorderWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    @IBInspectable public var stickSize: CGSize = CGSize(width: 250, height: 250) { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickColor: UIColor = UIColor.clear { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickBorderColor: UIColor = UIColor.clear { didSet { setNeedsDisplay() }}
    @IBInspectable public var stickBorderWidth: CGFloat = 1.0 { didSet { setNeedsDisplay() }}
    
    @IBInspectable public var fade: CGFloat = 0.1 { didSet { setNeedsDisplay() }}
    
    public var trackingHandler: ((CDJoystickData) -> Void)?
    public var delegate: JoystickDelegate?
    
    private var data = CDJoystickData()
    private var stickView = UIView(frame: .zero)
    private var displayLink: CADisplayLink?
    
    private var tracking = false {
        didSet {
//            UIView.animate(withDuration: 0.25) {
//                self.alpha = self.tracking ? 1.0 : self.fade
//            }
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        displayLink = CADisplayLink(target: self, selector: #selector(listen))
        displayLink?.add(to: .current, forMode: .commonModes)
        self.backgroundColor = UIColor.clear
    }
    
    public func listen() {
        guard tracking else { return }
        trackingHandler?(data)
    }
    
    public override func draw(_ rect: CGRect) {
        //alpha = fade
        
        layer.backgroundColor = UIColor.clear.cgColor //substrateColor.cgColor
        layer.borderColor = UIColor.clear.cgColor //substrateBorderColor.cgColor
        layer.borderWidth = substrateBorderWidth
        layer.cornerRadius = bounds.width / 2
        
        stickView.frame = CGRect(origin: .zero, size: stickSize)
        stickView.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        stickView.layer.backgroundColor = stickColor.cgColor
        stickView.layer.borderColor = stickBorderColor.cgColor
        stickView.layer.borderWidth = stickBorderWidth
        stickView.layer.cornerRadius = stickSize.width / 2
        
        if let superview = stickView.superview {
            superview.bringSubview(toFront: stickView)
        } else {
            addSubview(stickView)
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        tracking = true
        
        UIView.animate(withDuration: 0.1) {
            self.touchesMoved(touches, with: event)
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let distance = CGPoint(x: location.x - bounds.size.width / 2, y: location.y - bounds.size.height / 2)
        let magV = sqrt(pow(distance.x, 2) + pow(distance.y, 2))
        
        if magV <= stickView.frame.size.width {
            stickView.center = CGPoint(x: distance.x + bounds.size.width / 2, y: distance.y + bounds.size.height / 2)
        } else {
            let aX = distance.x / magV * stickView.frame.size.width
            let aY = distance.y / magV * stickView.frame.size.height
            stickView.center = CGPoint(x: aX + bounds.size.width / 2, y: aY + bounds.size.height / 2)
        }
        
        let x = clamp(distance.x, lower: -bounds.size.width / 2, upper: bounds.size.width / 2) / (bounds.size.width / 2)
        let y = clamp(distance.y, lower: -bounds.size.height / 2, upper: bounds.size.height / 2) / (bounds.size.height / 2)
        
        data = CDJoystickData(force: touch.force, velocity: CGPoint(x: x, y: y), angle: -atan2(x, y) + .pi, stickCenter: stickView.center)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reset()
    }
    
    private func reset() {
        tracking = false
        data = CDJoystickData()

        UIView.animate(withDuration: 0.25) {
            self.stickView.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            self.delegate?.stickDidResetTo(center: self.stickView.center)
        }
    }
    
    private func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
        return min(max(value, lower), upper)
    }
}
