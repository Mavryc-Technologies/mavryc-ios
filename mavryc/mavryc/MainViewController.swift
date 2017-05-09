//
//  MainViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var panelHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "JourneyPanelSegue" {
            let panel = segue.destination as? FlightPanelViewController
            panel?.delegate = self
        }
    }
}

extension MainViewController: PanelDelegate {
    
    func panelDidOpen() {
        print("opened")
    }
    
    func panelDidClose() {
        print("closed")
    }
    
    func panelExtendedHeight() -> CGFloat {
        return self.view.frame.height - (self.view.frame.height * 0.25) // 1/4 screen placement
    }
    
    func panelRetractedHeight() -> CGFloat {
        return 60
    }
    
    func panelLayoutConstraintToUpdate() -> NSLayoutConstraint {
        return self.panelHeightConstraint
    }
    
    func panelParentView() -> UIView {
        return self.view
    }
}
