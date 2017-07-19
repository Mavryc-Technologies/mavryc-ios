//
//  UIView+Gestures.swift
//  mavryc
//
//  Created by Todd Hopkinson on 7/19/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

extension UIView {
    
    func registerToBlockSwipeGestures(up: Bool, down: Bool, left: Bool, right: Bool) {
        if left {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleBlockingSwipe))
            swipeLeft.direction = .left
            self.addGestureRecognizer(swipeLeft)
        }

        if right {
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleBlockingSwipe))
            swipeRight.direction = .right
            self.addGestureRecognizer(swipeRight)
        }

        if up {
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleBlockingSwipe))
            swipeUp.direction = .up
            self.addGestureRecognizer(swipeUp)
        }

        if down {
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleBlockingSwipe))
            swipeDown.direction = .down
            self.addGestureRecognizer(swipeDown)
        }
    }
    
    func handleBlockingSwipe() {
        print("⛔️ swipe was blocked on a view registered to block swipes on itself: \(self)")
    }
}
