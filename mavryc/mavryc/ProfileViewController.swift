//
//  ProfileViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/10/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: IB outlets
    
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    // MARK: lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true

        self.updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.layer.masksToBounds = true
        
        self.updateUI()
    }
    
    // MARK: - UI Support
    func updateUI() {
        if let user = User.storedUser() {
            firstnameTextField.text = user.firstName
            lastnameTextField.text = user.lastName
            phoneNumberTextfield.text = user.phone
            emailTextfield.text = user.email
            passwordTextfield.text = user.password
        }
    }
    
    // MARK: - Control Methods
    @IBAction func closeButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name.SlideoutMenu.MenuSubScreenCloseWasTapped, object: self, userInfo:[:])
        self.dismiss(animated: true) {
            print("dismissed")
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        User.logout()
        self.dismiss(animated: true, completion: nil)
    }
    
}
