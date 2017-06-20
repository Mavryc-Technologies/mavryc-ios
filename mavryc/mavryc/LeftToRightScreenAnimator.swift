//
//  LeftToRightScreenAnimator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/20/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class LeftToRightScreenAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let containerView = transitionContext.containerView
        
        let screenOffLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
        let screenOffRight = CGAffineTransform(translationX: containerView.frame.width + containerView.frame.width, y: 0)
        
        containerView.addSubview(fromView)
        containerView.addSubview(toView)
        
        toView.transform = screenOffLeft
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.8,
                       options: [],
                       animations: {
                        fromView.transform = screenOffRight
                        toView.transform = CGAffineTransform.identity
        }) { (finished) in
            transitionContext.completeTransition(finished)
        }
    }
}
