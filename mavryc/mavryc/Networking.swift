//
//  Networking.swift
//  mavryc
//
//  Created by Todd Hopkinson on 4/4/17.
//  Copyright © 2017 Mavryc Technologies, Inc. All rights reserved.
//

import Foundation
import Alamofire

enum PlatformAPI {
    
    case fetchUser(userId: String)
    
    case signup(email: String,
            firstName: String,
            lastName: String,
            password: String,
            phone: String?,
            birthday: String?)
    
    case login(email: String, password: String)
    
    case fetchFlights()
}

//enum PlatformAuthenticatedAPI {
//    case fetchUserProfile(userId: String?)
//}

enum PlatformBaseUrl: String {
    case apiaryMock = "https://private-6f3e2-mavrycswaggerapi.apiary-mock.com"
    case development = "https://mavryc.herokuapp.com"
    case production = "https://www.mavrycapp.com" // TODO: update prod base url
}

protocol Path {
    var path: String { get }
}

protocol Routable: Path {
    var baseURL: URL { get }
}

protocol httpMethod: Path {
    var method: HTTPMethod { get }
}

/// A Payload to be used in platform requests for the given API.
protocol Payload: Path {
    var payload: [String: Any]? { get }
}

protocol ClientServerSecretHashable: Path {
    var hashedSecret: String? { get }
}

protocol ClientConfiguration {
    var securityTokenStoreKey: String { get }
    var securityTokenUrlParameter: String? { get set }
    func loggedIn(with securityToken: String?)
    func logout()
}


extension PlatformAPI: Path {
    
    var path: String {
        
        switch self {
            
        case .fetchUser(let userId): return "/users/\(userId)"
            
        case .signup(_,_,_,_,_,_): return "/signup"
        
        case .login(_,_): return "/login"
            
        case .fetchFlights(): return "/flights"
            
//        case .login(_, _, _): return "user.login"
//            
//        case .logout: return "user.logout"
//            
//        case .resetPassword(let username): return "user.resetPassword&username=\(username)"
//            
//        case .fetchUserProfile(let userId): return "user.fetchProfile&userId=\(userId)"
        }
    }
}

//extension PlatformAuthenticatedAPI: Path {
//    var path: String {
//        switch self {
//        case .fetchUserProfile: return "user.fetchProfile"
//        }
//    }
//}

extension PlatformAPI: httpMethod {
    
    var method: HTTPMethod {
        switch self {
        case .fetchUser(_):
            return HTTPMethod.get
        case .fetchFlights():
            return HTTPMethod.get
        case .signup(_, _, _, _, _, _):
            return HTTPMethod.post
        case .login(_,_):
            return HTTPMethod.post
//        default:
//            return HTTPMethod.get
        }
    }
}

extension PlatformAPI: Routable {
    
    var baseURL: URL {
        
        return URL(string: PlatformBaseUrl.apiaryMock.rawValue)!  // TEMP mock
        
        //let isDev = true // TODO: implement better environment switching
        //return isDev ? URL(string: PlatformBaseUrl.development.rawValue)! : URL(string: PlatformBaseUrl.production.rawValue)!
    }
}

//extension PlatformAuthenticatedAPI: Routable {
//    
//    var baseURL: URL {
//        let isDev = true // TODO: implement better environment switching
//        return isDev ? URL(string: PlatformBaseUrl.development.rawValue)! : URL(string: PlatformBaseUrl.production.rawValue)!
//    }
//}


extension PlatformAPI: ClientServerSecretHashable {
    
    var hashedSecret: String? {
        
        switch self {
            
//        case .login(_, _, _):
//            guard let deviceid = AppState.deviceID else { return nil }
//            let appsecret = Networking.sharedInstance.appSecret
//            let confirmation = "\(appsecret)\(deviceid)"
//            return confirmation.md5
//            
//        case .signup(let username, _, let firstname, let lastname,let phone, _, let facebookId,_):
//            let appsecret = Networking.sharedInstance.appSecret
//            var hashed = "\(appsecret)\(lastname ?? "")\(username ?? "")\(firstname ?? "")"
//            if let _ = facebookId {
//                hashed = "\(appsecret)Aren't you a little short for a storm trooper?"
//            }
//            if let _ = phone {
//                hashed = "\(appsecret)Aren't you a little short for a storm trooper?"
//            }
//            
//            if username == nil && facebookId == nil {
//                hashed = "\(appsecret)Aren't you a little short for a storm trooper?"
//            }
//            
//            return hashed.md5
//            
//        case .resetPassword(let username):
//            let appsecret = Networking.sharedInstance.appSecret
//            let hashed = "\(appsecret)\(username)"
//            return hashed.md5
            
        default: return nil
        }
    }
}

/// Define as needed for each API that requires a payload in addition to, or rather than, url encoded params
extension PlatformAPI: Payload {
    
    var payload: [String: Any]? {
        
        switch self {
            
        case .fetchUser(_):
            return nil
            
        case .signup(let email, let firstName, let lastName, let password, let phone, let birthday):
            var params = [String:String]()
            params["firstname"] = firstName
            params["lastname"] = lastName
            params["email"] = email
            params["password"] = password
            params["phone"] = phone // TODO: CHECK TO SEE WHETHER THE LET ABOVE IS AN OPTIONAL - if so then dicionary has a convenience unwrapper when adding if it knows the type should be String and the param is an optional with a string.
            params["birthday"] = birthday
            return params
        case .login(let email, let password):
            var params = [String:String]()
            params["email"] = email
            params["password"] = password
            return params
        case .fetchFlights():
//            var params = [String:String]()
            return [String:String]()
            
        //default: return nil
        }
    }
}

class Networking {
    
    static let sharedInstance = Networking()
    public var sessionManager: Alamofire.SessionManager
    
    private init() {
        let configuration = URLSessionConfiguration.default
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        sessionManager.session.configuration.httpCookieAcceptPolicy = .always
        sessionManager.session.configuration.httpCookieStorage = HTTPCookieStorage.shared
        self.sessionManager = sessionManager
    }
}

//extension Networking: ClientConfiguration {
//
//    /// app secret is used to establish base level application trust to server for client server communication - see
//    var appSecret: String {
//        return "DHpMX3HFTBkS3nHP6nTGc8OlNXTQhe0eH2t5upc"
//    }
//    
//    /// key for name value key pair for sending appSecret to platform
//    var confirmationAppSecretHashKey: String {
//        return "confirmation"
//    }
//    
//    var securityTokenStoreKey: String {
//        return "_tknKey"
//    }
//    
//    var securityTokenUrlParameter: String? {
//        get {
//            let token = UserDefaults.standard.string(forKey: "xssSecurityToken") ?? nil
//            return token
//        }
//        set(token) {
//            if let tokenString = token {
//                print("saving token: \(tokenString)")
//                UserDefaults.standard.set(tokenString, forKey: "xssSecurityToken")
//            } else {
//                print("removing securityToken from userDefaults")
//                UserDefaults.standard.removeObject(forKey: "xssSecurityToken")
//            }
//            UserDefaults.standard.synchronize()
//        }
//    }
//    
//    func loggedIn(with securityToken: String?) {
//        securityTokenUrlParameter = securityToken
//    }
//    
//    func logout() {
//        securityTokenUrlParameter = nil // removes xssSecurityToken - no auth'd call will work at this point
//    }
//}

/// Networking provider facilitating service requests
/// Use with URLSession or Alamofire to initiate and handle web service calls according to the PlatformAPI services
extension Networking {
    
    /// URL intended for a request such as Alamofire.request(url,...) based upon a give API's specifications - see PlatformAPI
    ///
    /// - parameter route: a PlatformAPI or PlatformAuthenticatedAPI adopting Routable protocol
    ///
    /// - returns: URL adhering to the signature specified in the PlatformAPI
    class func url(route: Routable) -> URL {
        let aBaseUrl = "\(route.baseURL)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let aPath = "\(route.path)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return URL(string: aBaseUrl + aPath)!
    }
    
    /// A payload (json encoded parameters) intended as an argument for a request such as Alamofire.request(..., params) based on given API's specs in PlatformAPI
    ///
    /// - parameter source: a designated PlatformAPI or PlatformAuthenticatedAPI adopting Payload protocol
    ///
    /// - returns: a json-formatted payload ready for inclusion as json in http body in a network request
    class func payload(source: Payload) -> [String: Any]? {
        return source.payload
    }
    
    class func httpMethod(source: httpMethod) -> HTTPMethod {
        return source.method
    }
}
