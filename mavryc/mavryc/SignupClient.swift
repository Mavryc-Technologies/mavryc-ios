//
//  SignupClient.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/7/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SignupClient {
    
    public func makeRequest(signup: SignupDTO, success: ((String) -> Void)?, failure: ((Error) -> Void)? ) {
        
        let api = PlatformAPI.signup(email: signup.email,
                                     firstName: signup.firstName,
                                     lastName: signup.lastName,
                                     password: signup.password,
                                     phone: signup.phone,
                                     birthday: signup.birthday)
        let url = Networking.url(route: api)
        let params = Networking.payload(source: api)
        let method = Networking.httpMethod(source: api)
        
        Networking.sharedInstance.sessionManager.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            switch response.result {
            case .success(let jsonData):
                
                let json:JSON = JSON(jsonData)
                SafeLog.print("response \(json)")
                
                success?(json.debugDescription)
                
            case .failure(let error):
                SafeLog.print(error)
                SafeLog.print("📡 response: \(response)")
                failure?(error)
            }
        }
    }
    
}
