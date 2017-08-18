//
//  LoginManager.swift
//  mavryc
//
//  Created by Todd Hopkinson on 8/16/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import UIKit
import LFLoginController

protocol LoginProtocol {
    func onLogin(success: Bool, manager: LoginManager, Login: LoginUser)
    func onLogout(manager: LoginManager)
//    func onForgotPassword(manager: LoginManager)
}

class LoginManager {
    
    static let shared = LoginManager()
    
    var listeners: [LoginProtocol] = []
}

extension LoginManager: LFLoginControllerDelegate {
    
    func loginDidFinish(email: String, password: String, type: LFLoginController.SendType) {
        
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
    
    func forgotPasswordTapped() {
        self.listeners.forEach { (listener) in
//            listener.onForgotPassword(manager: self)
        }
    }
    
}

