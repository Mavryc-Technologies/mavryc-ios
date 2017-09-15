//
//  LoginViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 9/13/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    
    @IBOutlet weak var loginButton: StyledButton! {
        didSet {
            loginButton.isEnabled = false
        }
    }
    
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!,
                                                                   attributes: [NSForegroundColorAttributeName: AppStyle.skylarBlueGrey])
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        didSet {
            passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!,
                                                                      attributes: [NSForegroundColorAttributeName: AppStyle.skylarBlueGrey])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    func updateUIForValidity() {
        
        // TODO: update textfield icons based on valid data
        
        if let _ = emailTextField.text,
            let _ = passwordTextField.text {
            loginButton.isEnabled = true
            
        } else {
            loginButton.isEnabled = false
        }
    }
    
    
    func swipeDown(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .down) {
            hideKeyboard()
            
            // save data
            //saveData()
        }
    }
    
    func hideKeyboard() {
        if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        }
        
        self.updateUIForValidity()
    }
    
    // MARK: - Keyboard
    
    func keyboardDidShow(notification : NSNotification){
        
        if emailTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: emailTextField, notification: notification)
        } else if passwordTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: passwordTextField, notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
            // offset from our navigation bar
            self.view.frame.origin = CGPoint(x: 0, y: 0)
            
        }, completion: nil)
        
        self.updateUIForValidity()
    }
    

    @IBAction func closeButtonTapAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginBottonAction(_ sender: Any) {
        if let email = emailTextField.text, let pass = passwordTextField.text {
            
            // TODO: service call to login and handle response
            
            // MOCK response here to be replaced with actual response handler
            let user = User(email: email, password: pass)
            user.save()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.default {
            
            // save data
            //saveData()
            
            if emailTextField.isFirstResponder {
                passwordTextField.becomeFirstResponder()
            } else if passwordTextField.isFirstResponder {
                passwordTextField.resignFirstResponder()
            }
            
            return false
            
        }
        return true
    }
}

