//
//  FlightPanelViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

protocol PanelDelegate {
    func panelDidOpen()
    func panelDidClose()
    func panelRetractedHeight() -> CGFloat
    func panelExtendedHeight() -> CGFloat
    func panelLayoutConstraintToUpdate() -> NSLayoutConstraint
    func panelParentView() -> UIView
}

class FlightPanelViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var panelButton: UIButton!
    
    var lastPanIncrement: CGFloat = 0
    var isOpen: Bool = false
    var delegate: PanelDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(recognizer:)))
        self.panelButton.addGestureRecognizer(gesture)
        self.panelButton.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    @IBAction func panelButtonAction(_ sender: Any) {
        self.isOpen = !isOpen
        self.activatePanel(open: self.isOpen)
    }
    
    private func activatePanel(open: Bool) {
        guard let delegate = delegate else { return }
        self.isOpen = open
        self.updateChevronForActivityState()
        delegate.panelLayoutConstraintToUpdate().constant = open ? delegate.panelExtendedHeight() : delegate.panelRetractedHeight()
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        delegate.panelParentView().layoutIfNeeded()
        }) { (success) in
            if open { delegate.panelDidOpen() } else { delegate.panelDidClose() }
//            if let welf = self {
//                welf.updateChevronForActivityState()
//            }
        }
    }
    
    private func updateChevronForActivityState() {
        let chevron = self.isOpen ? UIImage.init(imageLiteralResourceName: "down_chevron") : UIImage.init(imageLiteralResourceName: "up_chevron")
        self.panelButton.setImage(chevron, for: UIControlState.normal)
    }
    
    func wasDragged(recognizer: UIPanGestureRecognizer) {
        guard let delegate = delegate else { return }
        
        let panelHeightConstraint = delegate.panelLayoutConstraintToUpdate()
        let retractedHeight = delegate.panelRetractedHeight()
        let extendedHeight = delegate.panelExtendedHeight()
        let parentView = delegate.panelParentView()
        
        let panDidBeginOrDidChange = recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.changed
        let panDidEnd = recognizer.state == .ended
        
        let translation = recognizer.translation(in: parentView)
        
        if panDidBeginOrDidChange {
            lastPanIncrement = translation.y // used for determining direction when pan is done
            let intendedHeight = panelHeightConstraint.constant - translation.y
            if intendedHeight >= retractedHeight && intendedHeight <= extendedHeight {
                panelHeightConstraint.constant = panelHeightConstraint.constant - translation.y
            }
            recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
            
        } else if panDidEnd {
            if lastPanIncrement < 0 { // upward direction therefore open panel
                activatePanel(open: true)
            } else {
                activatePanel(open: false)
            }
        }
        
    }
    
    
}
