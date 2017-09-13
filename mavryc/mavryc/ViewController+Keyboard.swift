//
//  ViewController+Keyboard.swift
//  mavryc
//
//  Created by Todd Hopkinson on 9/12/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    // get first repsonder
    func getFirstResponder()->UIView?{
        
        var firstResponder : UIView?
        
        view.subviews.forEach { (subview) in
            if subview.isFirstResponder {
                firstResponder = subview
            }
        }
        return firstResponder
    }
    
    // extension method to check if the view in question is intercepting the keyboard and moves if needed
    func moveViewIfNeeded(hiddenView: UIView, notification: NSNotification){
        
        let hiddenViewRect = hiddenView.convert(hiddenView.bounds, to: self.view)
        
        if !hasExternalKeyboard(notification: notification){
            
            let userInfo = notification.userInfo as! [String: AnyObject]
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
            
            // 50 is the normal size for a tool bar so we subtract to get the new origin including the toolbar
            let keyboardWithToolbarOrigin = keyboardFrame!.origin.y - 50
            
            // if the view being check has an origin and height greater than the origin of the keyboard it is intercepting the keyboard
            let interception = keyboardWithToolbarOrigin  < hiddenViewRect.origin.y + hiddenViewRect.size.height
            
            // take the keyboard origin subtract it from the view being hidden then get the offest value from the bounds of the view
            let scrollTo = (keyboardWithToolbarOrigin - (hiddenViewRect.origin.y + hiddenViewRect.size.height)) - self.view.bounds.origin.y
            
            // we only want to move if the view is covered by keyboard
            if interception{
                UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: UIViewKeyframeAnimationOptions.beginFromCurrentState, animations: {
                    
                    self.view.frame.origin = CGPoint(x: 0.0, y: scrollTo)
                    
                }, completion: nil)
            }
        }
    }
    
    func removeTextFieldAssistant(textField: UITextField) {
        let item = textField.inputAssistantItem
        
        item.leadingBarButtonGroups = [UIBarButtonItemGroup]()
        item.trailingBarButtonGroups = [UIBarButtonItemGroup]()
    }
    
    // gets the next field tags need to be set up in interface builder
    func switchToNextTextField(currentField: UITextField){
        
        if let nextView = self.view.viewWithTag(currentField.tag + 1 ) as? UITextField{
            nextView.becomeFirstResponder()
        } else {
            currentField.resignFirstResponder()
        }
    }
    
    // a method that checks if there is a keyboard externally attached
    func hasExternalKeyboard(notification : NSNotification)->Bool{
        let userInfo = notification.userInfo as! [String: AnyObject]
        
        let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        
        //if let unwrapedField = selectedField{
        //for some reason in landscape our navigation bar height isn't correct and is actually 64
        let height = self.view.frame.size.height + 64
        //user using external keyboard
        return ((keyboardFrame!.origin.y + keyboardFrame!.size.height) > height)
    }
}
