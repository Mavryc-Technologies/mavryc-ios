//
//  SignupViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 9/13/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!  {
        didSet {
            nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!,
                                                                         attributes: [NSForegroundColorAttributeName: AppStyle.skylarBlueGrey])
        }
    }
    
    @IBOutlet weak var emailTextField: UITextField!  {
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
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!  {
        didSet {
            confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: confirmPasswordTextField.placeholder!,
                                                                         attributes: [NSForegroundColorAttributeName: AppStyle.skylarBlueGrey])
        }
    }
    
    @IBOutlet weak var signupButton: StyledButton! {
        didSet{
            signupButton.isEnabled = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }

    @IBAction func closeButtonTapAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func signupButtonAction(_ sender: Any) {
    
        // Code to hide the keyboards for text fields
        if self.nameTextField.isFirstResponder {
            self.nameTextField.resignFirstResponder()
        }
        
        if self.emailTextField.isFirstResponder {
            self.emailTextField.resignFirstResponder()
        }
        
        if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
        
        if self.confirmPasswordTextField.isFirstResponder {
            self.confirmPasswordTextField.resignFirstResponder()
        }
        
        // start activity indicator
        //self.activityIndicatorView.hidden = false
        
        // validate presence of all required parameters
        if let nameString = nameTextField.text,
            let emailString = emailTextField.text,
            let pass = passwordTextField.text,
            let _ = confirmPasswordTextField.text {
            
            // TODO: make request here to signup 
            // NOTE: IN LEIU OF RESPONSE, mock the next response and saving - this code belongs in the signup request response handler
            let user = User(email: emailString, password: pass)
            user.firstName = nameString
            user.save()
            self.dismiss(animated: true, completion: nil)
        } else {
//            self.displayAlertMessage("Parameters Required", alertDescription:
//                "Some of the required parameters are missing")
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
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        } else if emailTextField.isFirstResponder {
            emailTextField.resignFirstResponder()
        } else if passwordTextField.isFirstResponder {
            passwordTextField.resignFirstResponder()
        } else if confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.resignFirstResponder()
        }
        
        self.updateUIForValidity()
    }
    
    func updateUIForValidity() {
        
        // TODO: update textfield icons based on valid data
        
        if let _ = nameTextField.text,
            let _ = emailTextField.text,
            let _ = passwordTextField.text,
            let _ = confirmPasswordTextField.text {

            signupButton.isEnabled = true
            
        } else {
            signupButton.isEnabled = false
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardDidShow(notification : NSNotification){
        
        if nameTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: nameTextField, notification: notification)
        } else if emailTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: emailTextField, notification: notification)
        } else if passwordTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: passwordTextField, notification: notification)
        } else if confirmPasswordTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: confirmPasswordTextField, notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
            // offset from our navigation bar
            self.view.frame.origin = CGPoint(x: 0, y: 0)
            
        }, completion: nil)
        
        self.updateUIForValidity()
    }
}

extension SignupViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.default {
            
            // save data
            //saveData()
            
            if nameTextField.isFirstResponder {
                emailTextField.becomeFirstResponder()
            } else if emailTextField.isFirstResponder {
                passwordTextField.becomeFirstResponder()
            } else if passwordTextField.isFirstResponder {
                confirmPasswordTextField.becomeFirstResponder()
            } else if confirmPasswordTextField.isFirstResponder {
                confirmPasswordTextField.resignFirstResponder()
                return true
            }
            
            return false
            
        }
        return true
    }
}
