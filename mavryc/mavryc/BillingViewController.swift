//
//  BillingViewController.swift
//  mavryc
//
//  Created by Todd Hopkinson on 9/8/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

@objc protocol BillingDelegate {
    func closeWasTapped()
}

class BillingViewController: UIViewController {
    
    // MARK: - Properties
    weak var delegate: BillingDelegate?
    
    @IBOutlet weak var creditCardLogoImageView: UIImageView!
    @IBOutlet weak var creditCardTypeNameLabel: UILabel!
    
    @IBOutlet weak var cardNumberTextField: UITextField!
    @IBOutlet weak var expirationTextField: UITextField!
    @IBOutlet weak var ccvTextField: UITextField!
    @IBOutlet weak var cardholderNameTextField: UITextField!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardNumberTextField.delegate = self
        expirationTextField.delegate = self
        ccvTextField.delegate = self
        cardholderNameTextField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
        swipeDownGesture.direction = .down
        self.view.addGestureRecognizer(swipeDownGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // populate UI
        let billingInfo = fetchBillingData()
        cardNumberTextField.text = billingInfo?.creditCardNumber
        expirationTextField.text = billingInfo?.expirationDate
        ccvTextField.text = billingInfo?.ccv
        cardholderNameTextField.text = billingInfo?.cardholderName
    }
    
    // MARK: - Data
    
    func fetchBillingData() -> Billing? {
        return Billing.storedBillingInfo()
    }
    
    // TODO: Lock it down. For production, you're really going to want to store this more securely in the keychain rather than userdefaults. This will suffice for an alpha type release
    func saveData() {
        guard let ccNumber = cardNumberTextField.text else { return }
        guard let expiration = expirationTextField.text else {return}
        guard let ccv = ccvTextField.text else {return}
        guard let name = cardholderNameTextField.text else {return}
        
        let data = Billing(creditCardNumber: ccNumber, expirationDate: expiration, ccv: ccv, cardholderName: name)
        data.save()
    }
    
    // MARK: - Control Methods
    
    @IBAction func closeButtonAction(_ sender: Any) {
        delegate?.closeWasTapped()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Keyboard
    
    func keyboardDidShow(notification : NSNotification){
        
        if cardNumberTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: cardNumberTextField, notification: notification)
        } else if expirationTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: expirationTextField, notification: notification)
        } else if ccvTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: ccvTextField, notification: notification)
        } else if cardholderNameTextField.isFirstResponder {
            moveViewIfNeeded(hiddenView: cardholderNameTextField, notification: notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
            // offset from our navigation bar
            self.view.frame.origin = CGPoint(x: 0, y: 0)
            
        }, completion: nil)
    }
    
    func swipeDown(sender: UISwipeGestureRecognizer) {
        if (sender.direction == .down) {
            hideKeyboard()
            
            // save data
            saveData()
        }
    }
    
    func hideKeyboard() {
        if cardNumberTextField.isFirstResponder {
            cardNumberTextField.resignFirstResponder()
        } else if expirationTextField.isFirstResponder {
            expirationTextField.resignFirstResponder()
        } else if ccvTextField.isFirstResponder {
            ccvTextField.resignFirstResponder()
        } else if cardholderNameTextField.isFirstResponder {
            cardholderNameTextField.resignFirstResponder()
        }
    }
    


}

extension BillingViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == UIReturnKeyType.default {
            
            // save data
            saveData()
            
            if cardNumberTextField.isFirstResponder {
                expirationTextField.becomeFirstResponder()
            } else if expirationTextField.isFirstResponder {
                ccvTextField.becomeFirstResponder()
            } else if ccvTextField.isFirstResponder {
                cardholderNameTextField.becomeFirstResponder()
            } else if cardholderNameTextField.isFirstResponder {
                cardholderNameTextField.resignFirstResponder()
                return true
            }
            
            return false
            
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == cardNumberTextField {
            return validateLength(string: textField.text!, maxAllowedLength: 12)
        }
        
        if textField == expirationTextField { // Expiry Date Text Field
            return validateLength(string: textField.text!, maxAllowedLength: 3)
        }
        
        if textField == ccvTextField {
            return validateLength(string: textField.text!, maxAllowedLength: 2)
        }
        
        return true
    }
    
    func validateLength(string: String, maxAllowedLength: Int) -> Bool {
        let stringLength = (string as NSString).length
        return (stringLength > maxAllowedLength) ? false : true
    }
}
