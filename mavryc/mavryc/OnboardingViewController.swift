//
//  OnboardingViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/3/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipButtonAction(_ sender: Any) {
        SafeLog.print("skip button pressed")
        AppCoordinator.dismissFeature(viewController: self)
    }

}
