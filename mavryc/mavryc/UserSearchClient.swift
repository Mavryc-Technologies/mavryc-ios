//
//  UserSearchClient.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/4/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class UserSearchClient {
    
    public func makeRequest(email: String, success: ((String) -> Void)?, failure: ((Error) -> Void)? ) {
        
        let api = PlatformAPI.searchUser(email: email)
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
