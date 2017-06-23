//
//  FlightPanelViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 5/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

protocol PanelDelegate {
    /// notify delegate when panel did open
    func panelDidOpen()
    
    /// notify delegate when panel did close
    func panelDidClose()
    
    func panelWillClose()
    
    /// delegate provides desired height of panel in retracted state
    func panelRetractedHeight() -> CGFloat
    
    /// delegate provides desired height of panel in extended state
    func panelExtendedHeight() -> CGFloat
    
    /// delegate provides layout constraint to update (panel height)
    func panelLayoutConstraintToUpdate() -> NSLayoutConstraint
    
    /// delegate provides the parent view of the parent to which panel has been added
    func panelParentView() -> UIView
}

class FlightPanelViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var fxBGView: UIVisualEffectView!
    
    @IBOutlet weak var panelButton: UIButton! // contains chevron images
    
    @IBOutlet weak var panelTopBorder: UIView!
    
    @IBOutlet weak var panelTitleLabel: UILabel!
    
    
    var delegate: PanelDelegate?
    
    private var lastPanIncrement: CGFloat = 0
    public var isOpen: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScreenNavigator.sharedInstance.registerPanelController(panelController: self)
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(recognizer:)))
        self.panelButton.addGestureRecognizer(gesture)
        self.panelButton.isUserInteractionEnabled = true
        gesture.delegate = self
    }
    
    func refreshCurrentPanelScreen() {}
    
    // MARK: - Panel Control
    
    /// Open panel and set to state
    public func triggerPanel(shouldOpen: Bool) {
        
        self.activatePanel(open: shouldOpen)
    }
    
    /// Triggers automatic panel extension/retraction when panelButton is normal pressed
    @IBAction func panelButtonAction(_ sender: Any) {
        self.isOpen = !isOpen
        self.activatePanel(open: self.isOpen)
    }
    
    /// Causes panel to open or close based on bool param
    private func activatePanel(open: Bool) {
        guard let delegate = delegate else { return }
        self.isOpen = open
        self.updateChevronForActivityState(isOpenState: open)
        self.updateBorderForActivityState(isOpenState: open)
        delegate.panelLayoutConstraintToUpdate().constant = open ? delegate.panelExtendedHeight() : delegate.panelRetractedHeight()
        
        if open {
            NotificationCenter.default.post(name: Notification.Name.PanelScreen.WillOpen, object: self, userInfo:nil)
        } else {
            delegate.panelWillClose()
            NotificationCenter.default.post(name: Notification.Name.PanelScreen.WillClose, object: self, userInfo:nil)
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 0,
                       options: .curveEaseOut,
                       animations: {
                        delegate.panelParentView().layoutIfNeeded()
        }) { (success) in
            if open {
                delegate.panelDidOpen()
                
                NotificationCenter.default.post(
                    name: Notification.Name.PanelScreen.DidOpen,
                    object: self,
                    userInfo: nil
                )

            } else {
                delegate.panelDidClose()
                
                NotificationCenter.default.post(
                    name: Notification.Name.PanelScreen.DidOpen,
                    object: self,
                    userInfo: nil
                )
            }
        }
    }
    
    /// Updates chevron to correct appearance for current state
    private func updateChevronForActivityState(isOpenState: Bool) {
        let chevron = isOpenState ? UIImage.init(imageLiteralResourceName: "down_chevron") : UIImage.init(imageLiteralResourceName: "up_chevron")
        self.panelButton.setImage(chevron, for: UIControlState.normal)
    }
    
    private func updateBorderForActivityState(isOpenState: Bool) {
        self.panelTopBorder.isHidden = isOpenState
    }
    
    /// Handles pull-up pull-down behavior, called by pan gesture recognizer on panelButton
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

// MARK: - Screen Navigation
extension FlightPanelViewController: ScreenNavigable {
    
    func screenNavigator(_ screenNavigator: ScreenNavigator, backButtonWasPressed: Bool) {
        self.triggerPanel(shouldOpen: false)
    }
    
    func screenNavigatorIsScreenVisible(_ screenNavigator: ScreenNavigator) -> Bool? {
        return self.isOpen
    }
    
    func screenNavigatorRefreshCurrentScreen(_ screenNavigator: ScreenNavigator) {
        let screen = screenNavigator.currentPanelScreen
        self.panelButton.isHidden = !screen.shouldShowChevron()
        self.panelTitleLabel.text = screen.panelTitle()
    }
}
