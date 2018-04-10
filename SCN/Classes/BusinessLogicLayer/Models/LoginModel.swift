//
//  LoginModel.swift
//  SCN
//
//  Created by BAMFAdmin on 12.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class LoginModel: Object {

    
    @objc dynamic var login: String?
    @objc dynamic var password: String?
    @objc dynamic var token: String?
    @objc dynamic var tokenType: String?
    @objc dynamic var startDate: Date?
    @objc dynamic var timeLifeInSeconds = 28700.0 //28800:480m
    
    static func tokenIsValid() -> Bool {
        if RealmService.getLoginModel().count > 0 {
            let date = Date()
            let timeFromLogin = date.timeIntervalSince(RealmService.getLoginModel()[0].startDate!)
            let timeFromLoginDouble = Double(timeFromLogin)
            if timeFromLoginDouble > RealmService.getLoginModel()[0].timeLifeInSeconds {
                RealmService.deleteLoginData()
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
}
