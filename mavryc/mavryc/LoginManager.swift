//
//  LoginManager.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/16/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import LFLoginController

protocol LoginMulticastDelegate {
    func identifier() -> String
    func onLogin(success: Bool, manager: LoginManager, Login: LoginUser)
    func onLogout(manager: LoginManager)
//    func onForgotPassword(manager: LoginManager)
}

func ==(lhs: LoginMulticastDelegate, rhs: LoginMulticastDelegate) -> Bool {
    return lhs.identifier() == rhs.identifier()
}

func !=(lhs: LoginMulticastDelegate, rhs: LoginMulticastDelegate) -> Bool {
    return lhs.identifier() != rhs.identifier()
}

class LoginManager {
    
    static let shared = LoginManager()
    
    public weak var loginViewController: LFLoginController? = nil
    
    fileprivate var listeners: [LoginMulticastDelegate] = []
    
    public func registerLoginMulticastDelegate(listener: LoginMulticastDelegate) {
        
        let listenerId = listener.identifier()
        
        if let foundIndex = self.listeners.index(where: { (aListener) -> Bool in
            if listenerId == aListener.identifier() { return true }
            return false
        })
        {
            self.listeners.remove(at: foundIndex)
        }
        
        self.listeners.append(listener)
    }
    
    public func presentLoginScreen(sender: UIViewController, delegate: LoginMulticastDelegate) {
        let login = LFLoginController()
        login.view.backgroundColor = AppStyle.skylarDeepBlue
        login.loginButtonColor = AppStyle.skylarGold
        
        self.loginViewController = login
        login.delegate = self
        
        self.registerLoginMulticastDelegate(listener: delegate)
        
        sender.show(login, sender: self)
    }
    
    public func presentLoginScreen(sender: UIViewController) {
        let login = LFLoginController()
        login.view.backgroundColor = AppStyle.skylarDeepBlue
        login.loginButtonColor = AppStyle.skylarGold
        
        self.loginViewController = login
        login.delegate = self
        
        if let sendr = sender as? LoginMulticastDelegate {
            self.registerLoginMulticastDelegate(listener: sendr)
        }
        
        sender.show(login, sender: self)
    }
    
    public func dismissLoginScreen() {
        self.loginViewController?.dismiss(animated: true, completion: {
            print("login dismissed")
        })
    }
}

extension LoginManager: LFLoginControllerDelegate {
    
    func loginDidFinish(email: String, password: String, type: LFLoginController.SendType) {
        
        if !email.isEmpty && !password.isEmpty {
            
            // TODO: proceed for demonstration purposes as if LoginAPI or Signin API succeeded
            let appUser = User(email: email, password: password)
            appUser.save()
            
            if type == .Login {
                
                // TODO: implement API call to login - returns LoginUser on success
                let user = LoginUser(email: email, password: password)
                
                self.listeners.forEach { (listener) in
                    listener.onLogin(success: true, manager: self, Login: user)
                }
            } else {
                
                // TODO: implement API call to signup - returns LoginUser on success
                let user = LoginUser(email: email, password: password)
                
                self.listeners.forEach { (listener) in
                    listener.onLogin(success: true, manager: self, Login: user)
                }
            }
        }
    }
    
    func forgotPasswordTapped() {
        self.listeners.forEach { (listener) in
//            listener.onForgotPassword(manager: self)
        }
    }
    
}

