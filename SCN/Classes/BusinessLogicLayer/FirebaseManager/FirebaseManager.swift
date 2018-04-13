//
//  FirebaseManager.swift
//  SCN
//
//  Created by BAMFAdmin on 12.04.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import Firebase

class FirebaseManager {
    
    var ref: DatabaseReference!
   
    func fetchConfigurationFromFirebase() {
        
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! [String: Any]
            let parsedLogoutList = value["auto_logout"] as! [[String: Any]]
            let parsedSecurityList = value["content_enable"] as! [[String: Any]]

            guard let timeForLogout = parsedLogoutList[0]["time_in_minutes"] as? String else {
                return
            }
            guard let contentEnable = parsedSecurityList[0]["value"] as? String else {
                return
            }
            let timeInMinutes = Double(timeForLogout)!
            var contentIsEnabled = false
            if contentEnable == "yes" {
                contentIsEnabled = true
            } else {
                contentIsEnabled = false
            }
            UserDefaults.standard.set(timeInMinutes, forKey: "timeForLogout")
            UserDefaults.standard.set(contentIsEnabled, forKey: "contentIsEnabled")
        }
    }
    
    func fetchSitesFromFirebase() -> [String] {
        var sitesList = [String]()
        
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! [String: Any]
            let parsedSitesList = value["sites"] as! [[String: Any]]
            
            for element in parsedSitesList {
                sitesList.append(element["url"] as! String)
            }
        }
        print(sitesList)
        return sitesList
    }
    
}
