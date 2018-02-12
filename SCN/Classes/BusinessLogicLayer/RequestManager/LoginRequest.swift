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
            //let url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/Plan/Public/MobileAuthenticate"
            let url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/PLAN/token"
            print(url)
//            let parameters: Parameters = [
//                "Username": login,
//                "Password": password
//            ]
        let parameters: Parameters = [
            "grant_type": "password",
            "username": login,
            "password": password
        ]

        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                .validate()
                .responseJSON{ (response) in

                    let statusCode = response.response?.statusCode

                    if statusCode == 404 || statusCode == 1001 {
                        completion(false, 404)
                    }
                    if statusCode == 400 {
                        completion(false, 200)
                    }
                    if let _ = response.error {
                        completion(false, 404)
                    } else {
                        
                        if (response.result.value != nil) {
                            let responseDictionary = response.result.value as! [String: Any]
                            RealmService.deleteLoginData()
                            let loginInstance = LoginModel()
                            loginInstance.startDate = Date()
                            loginInstance.login = login
                            loginInstance.token = (responseDictionary["access_token"] as! String)
                            loginInstance.tokenType = (responseDictionary["token_type"] as! String)
                            loginInstance.password = password
                            RealmService.writeIntoRealm(object: loginInstance)
                            print("FINE")
                            completion(true, 200)
                        }
                    }
            }
        }
}







