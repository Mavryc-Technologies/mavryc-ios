//
//  LoginClient.swift
//  mavryc
//
//  Created by Jake on 4/26/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


class LoginClient {
    
    public func makeLoginRequest(login: LoginDTO, success: ((String) -> Void)?, failure: ((Error) -> Void)? ) {
        let api = PlatformAPI.login(email: login.email, password: login.password)
        let url = Networking.url(route: api)
        let params = Networking.payload(source: api)
        let method = Networking.httpMethod(source: api)
        
        Networking.sharedInstance.sessionManager.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            switch response.result {
            case .success(let jsonData):
                
                let json:JSON = JSON(jsonData)
                print("response \(json)")
                
                success?(json.debugDescription)
                
            case .failure(let error):
                print(error)
                print("📡 response: \(response)")
                failure?(error)
            }
        }
    }
}
