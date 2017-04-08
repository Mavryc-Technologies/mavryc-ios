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
        
        Networking.sharedInstance.sessionManager.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            switch response.result {
            case .success(let jsonData):
                
                let json:JSON = JSON(jsonData)
                SafeLog.print("response \(json)")
                
                //                do {
                //                    try json.validatePlatformResponseSuccess()
                //                } catch  {
                //                    failure?(error)
                //                    print("📡 response: \(response)")
                //                    return
                //                }
                
                // Parse the user object
                //                do {
                //                    if let user = try User.parseServerData(json: json) {
                //                        success?(user)
                success?(json.debugDescription)
                //                        return
                //                    }
                //                } catch {
                //                    print("caught thrown parsing error")
                //                    failure?(error)
                //                    print("📡 response: \(response)")
                //                    return
                //                }
                
                //                failure?(NSError(domain: "httpresponsesuccessful.butnotreally.somethingiswrong", code: 999, userInfo: nil))
                
            case .failure(let error):
                SafeLog.print(error)
                SafeLog.print("📡 response: \(response)")
                failure?(error)
            }
        }
    }
    
}
