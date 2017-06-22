//
//  TransitionAnimator.swift
//  mavryc
//
//  Created by Todd Hopkinson on 6/19/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class RightToLeftScreenAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
//        guard let fromView = transitionContext.view(forKey: .from) else { return }
//        guard let toView = transitionContext.view(forKey: .to) else { return }
//        let containerView = transitionContext.containerView
//        
//        let screenOffLeft = CGAffineTransform(translationX: -containerView.frame.width, y: 0)
//        let screenOffRight = CGAffineTransform(translationX: containerView.frame.width + containerView.frame.width, y: 0)
//        
//        containerView.addSubview(fromView)
//        containerView.addSubview(toView)
//        
//        toView.transform = screenOffRight
//        
//        UIView.animate(withDuration: 0.5,
//                       delay: 0.0,
//                       usingSpringWithDamping: 0.8,
//                       initialSpringVelocity: 0.8,
//                       options: [],
//                       animations: {
//                            fromView.transform = screenOffLeft
//                            toView.transform = CGAffineTransform.identity
//                        }) { (finished) in
//                            transitionContext.completeTransition(finished)
//                        }
        
        
        //Get references to the view hierarchy
        let fromViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController: UIViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let sourceRect: CGRect = transitionContext.initialFrame(for: fromViewController)
        let containerView: UIView = transitionContext.containerView
        
        // The canvas is used for all animation and discarded at the end
        let canvas = UIView(frame: containerView.bounds)
        containerView.addSubview(canvas)
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        toView.frame = transitionContext.finalFrame(for: toViewController)
        toView.layoutIfNeeded()
        let toSnap = canvas.snapshot(view: toView, afterUpdates: true)!
        
            //1. Settings for the fromVC ............................
            //            fromViewController.view.frame = sourceRect
            let fromSnap = canvas.snapshot(view: fromView, afterUpdates: false)!
            fromView.removeFromSuperview()
            fromSnap.layer.anchorPoint = CGPoint(x: 0.5, y: 3);
            fromSnap.layer.position = CGPoint(x: fromViewController.view.frame.size.width/2, y: fromViewController.view.frame.size.height * 3);
            
            //2. Setup toVC view...........................
            toSnap.layer.anchorPoint = CGPoint(x: 0.5, y: 3);
            toSnap.layer.position = CGPoint(x: toViewController.view.frame.size.width/2, y: toViewController.view.frame.size.height * 3);
            toSnap.transform = CGAffineTransform(rotationAngle: 15 * CGFloat(Double.pi / 180));
            
            //3. Perform the animation...............................
            UIView.animate(withDuration: 0.45, delay:0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
                fromSnap.transform = CGAffineTransform(rotationAngle: -15 * CGFloat(Double.pi / 180));
                toSnap.transform = CGAffineTransform(rotationAngle: 0);
            }, completion: {
                (animated: Bool) -> () in
                containerView.insertSubview(toViewController.view, belowSubview:canvas)
                canvas.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
    }
}

extension UIView {
    func snapshot(view: UIView, afterUpdates: Bool) -> UIView? {
        guard let snapshot = view.snapshotView(afterScreenUpdates: afterUpdates) else { return nil }
        self.addSubview(snapshot)
        snapshot.frame = convert(view.bounds, from: view)
        return snapshot
    }
}
