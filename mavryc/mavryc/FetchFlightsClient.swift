//
//  FetchFlightsClient.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/5/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class FetchFlightsClient {
    
    public func makeRequest(dto: FetchFlightsDTO, success: (([Flight]) -> Void)?, failure: ((Error) -> Void)? ) {
        
        let api = PlatformAPI.fetchFlights()
        let url = Networking.url(route: api)
        let params = Networking.payload(source: api)
        let method = Networking.httpMethod(source: api)
        
        Networking.sharedInstance.sessionManager.request(url, method: method, parameters: params, encoding: URLEncoding.default, headers: nil).validate().responseJSON { response in
            
            print("\(response)")
            
            switch response.result {
            case .success(let jsonData):
                
                if let flights: Array<Flight> = Mapper<Flight>().mapArray(JSONObject: jsonData) {
                    success?(flights)
                } else {
                    let error = NSError(domain: "error.parsing.fetchFlights.serverResponse", code: 999, userInfo: ["jsonData":"\(jsonData)", "response":"\(response)", "result":"\(response.result)"])
                    SafeLog.print(error)
                    failure?(error)
                }
                
            case .failure(let error):
                SafeLog.print(error)
                SafeLog.print("📡 response: \(response)")
                failure?(error)
            }
        }
    }
    
}
