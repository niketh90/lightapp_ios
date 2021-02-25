//
//  JD_API.swift
//  Light
//
//  Created by Jaskirat on 23/04/20.
//  Copyright © 2020 Seraphic. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import AVFoundation

enum HTTPMethod:String {
    
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    
    func getRawValue() -> String {
        return self.rawValue
    }
}

enum ApiName: String {
    
    case signUp = "signup"
    case login = "login"
    case googleSignIn = "auth/google"
    case facebookSignIn = "auth/facebook"
    case appleLogin = "auth/apple"
    case logout = "signout"
    case getSessions = "getallsessions"
    case updateFrofile = "updateprofile"
    case updateFrofilePic = "updateprofilepic"
    case changePassword = "change-password"
    case changeSocialPass = "setpassword"
    case forgotPassword = "forgot-password"
    case searchSession = "getsessions"
    case updatestats = "updatestats"
    case ratesession = "ratesession"
    case InApp_Savereceipt = "savereceipt"
    case InApp_Verify = "iosverify"
}


class ServiceHelper:NSObject, NVActivityIndicatorViewable {
    static let client_Server = "https://api.lightforcancer.com/"
    
    static let our_Server = "http://ec2-3-21-237-151.us-east-2.compute.amazonaws.com:8080/"
    
    static let baseUrl = client_Server
    
    static let shared = ServiceHelper()
    
    var currentButtonState: String?
    
    func sendAsyncRequestWith(withParam param: [String:Any]?, httpMethod requestType: HTTPMethod, apiName requestName:ApiName,showHud show:Bool?, completionHandler:@escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void )  {
        let url = URL(string: "\(ServiceHelper.baseUrl)\(requestName.rawValue)")
        
        guard let requestUrl = url else { fatalError() }
        
        
        var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        var authentication :[String:String] = ["Content-Type":"application/json"]
        
        if requestName != .login, requestName != .signUp, requestName != .googleSignIn, requestName != .facebookSignIn {
            authentication["Authorization"] = getUserDetails()?.token
        }
        request.allHTTPHeaderFields = authentication
        
        request.httpMethod = requestType.rawValue
        
        switch requestType {
        case .post, .patch, .put, .delete:
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: param ?? [String:Any](), options: [])
                request.httpBody = jsonData
            } catch {
                print(error.localizedDescription)
            }
            
        default:
            break
        }
        
        if show == true {
            //  NVActivityIndicatorPresenter.sharedInstance.setMessage("Done")
            self.showIndicator()
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completionHandler(data, response, error)
                self.stopIndicator()
            }
        }
        task.resume()
    }
    
    
    func uploadProfilePic(withImage image:UIImage?, uploadFileParam fileParam:String, withApiName requestName:ApiName, requestType type:HTTPMethod, showHud show:Bool?, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        
        let url = URL(string: "\(ServiceHelper.baseUrl)\(requestName.rawValue)")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        request.httpMethod = type.rawValue
        
        let boundary = ServiceHelper.generateBoundaryString()
        let token = getUserDetails()?.token ?? ""
        
        print(token)
        let authentication :[String:String] = ["content-Type" :"multipart/form-data; boundary=\(boundary)", "Authorization":token]
        
        request.allHTTPHeaderFields = authentication
        
        print(request.allHTTPHeaderFields)
        
        var data = Data()
        
        //Add Params
        /* if let parameters = params {
         for (key, value) in parameters {
         data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
         data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
         data.append("\(value)".data(using: .utf8)!)
         }
         }*/
        
        //
        
        //Add Image
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {return}
        let filename = "\(arc4random()).jpg"
        let mimetype = "image/jpg"
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fileParam)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        //
        
        request.httpBody = data
        
        if show == true {
            NVActivityIndicatorPresenter.sharedInstance.setMessage("Done")
            self.showIndicator()
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
            self.stopIndicator()
        }
        task.resume()
    }
    
    class func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    //MARK: Indicator
    func showIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(ActivityData(type: .lineScaleParty, color: .white))
    }
    func stopIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}               
