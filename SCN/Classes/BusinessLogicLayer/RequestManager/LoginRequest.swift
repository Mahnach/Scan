//
//  LoginRequest.swift
//  SCN
//
//  Created by BAMFAdmin on 12.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class LoginRequest {
    
    static func loginRequest(login: String, password: String, completion: @escaping (Bool, Int) -> Void) {
            let url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/Plan/Public/MobileAuthenticate"
            
            let parameters: Parameters = [
                "Username": login,
                "Password": password
            ]
            
            var headers = [String: String]()
            
            headers = [
                "Content-Type": "application/json"
            ]
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON{ (response) in
                    let statusCode = response.response?.statusCode
                    if statusCode == 404 || statusCode == 1001 {
                        completion(false, 404)
                    }
                    if let _ = response.error {
                        completion(false, 404)
                    } else {
                        if (response.result.value != nil) {
                            let responseString = response.result.value as! String
                            print(responseString)
                            switch responseString {
                            case "Ok":
                                completion(false, 200)
                                break
                            case "User not found":
                                completion(false, 200)
                                break
                            default:
                                RealmService.deleteLoginData()
                                let loginInstance = LoginModel()
                                loginInstance.login = login
                                loginInstance.password = password
                                loginInstance.token = responseString
                                loginInstance.startDate = Date()
                                RealmService.writeIntoRealm(object: loginInstance)
                                print("FINE")
                                completion(true, 200)
                                break
                            }
                        }
                    }
            }
        }
}







