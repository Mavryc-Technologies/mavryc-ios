//
//  ProfileViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/10/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name.SlideoutMenu.MenuSubScreenCloseWasTapped, object: self, userInfo:[:])
        self.dismiss(animated: true) { 
            print("dismissed")
        }
    }
}
