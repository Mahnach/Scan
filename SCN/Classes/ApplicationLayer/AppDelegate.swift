//
//  AppDelegate.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import Firebase
import Siren

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        FirebaseApp.configure()
        
        let siren = Siren.shared
        siren.alertType = .force
        siren.alertMessaging = SirenAlertMessaging(updateTitle: "Update Available", updateMessage: "A new version of Accelify Scan is available. Please update application now.", updateButtonMessage: "Update", nextTimeButtonMessage: "Update", skipVersionButtonMessage: "Update")
        siren.showAlertAfterCurrentVersionHasBeenReleasedForDays = 3
        siren.checkVersion(checkType: .immediately)
        
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        } else {
            print("First launch, setting UserDefault.")
            RealmService.deleteSettingsSites()
            RealmService.deleteWebsite()
            RealmService.deleteLoginData()
            RealmService.deleteDefaultUserName()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .immediately)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Siren.shared.checkVersion(checkType: .daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

