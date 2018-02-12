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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

/* BROWARD
     STUDENT : <data><ProgramType>2</ProgramType><Customer>Broward</Customer><StudentId>0606113868</StudentId><StudentName>AARHUS, ANDREAS</StudentName><StudentAutoId>463611</StudentAutoId><DistrictId>81</DistrictId></data>
     
     DISTRIBUTION : <data><FileUniqueName>2359a9ff-3304-4a69-9c90-0032b9ebaad8</FileUniqueName><Customer>Broward</Customer><SubType>1</SubType><EventId>268bcb9c-ca6a-4937-a1a9-a74e00c6a05d</EventId><EventName>504 Notice of Eligibility Meeting (4/14/2017)</EventName><FormId>9baaf941-c678-4cb8-a1d2-a74e00c6a06a</FormId><FormName>Parent/Guardian Section 504 Meeting Notification</FormName><StudentId>0606113868</StudentId><StudentName>AARHUS, ANDREAS</StudentName><StudentAutoId>463611</StudentAutoId><DistrictId>81</DistrictId></data>
  
     
     DADE:
     <data><FileUniqueName>65194e0a-756a-4469-b4cc-0319c020b63e</FileUniqueName><Customer>Miami</Customer><SubType>1</SubType><EventId>d57dc548-474b-483d-b2a4-a714007286f9</EventId><EventName>IEP Notice of Annual Meeting (2/7/2018)</EventName><FormId>1d8a6fa5-e1cc-404d-a0b0-a71400728707</FormId><FormName>Notice of Meeting</FormName><StudentId>0241236</StudentId><StudentName>RONDON, FRANCISCO</StudentName><StudentAutoId>446756</StudentAutoId><DistrictId>93</DistrictId></data>
     
     
     DC:
     <data><ProgramType>9</ProgramType><Customer>DC</Customer><StudentId>9020529399</StudentId><StudentName>Abbott, Raynard</StudentName><StudentAutoId>13916</StudentAutoId><DistrictId>67</DistrictId></data>
     
     WASHOE:
     <data><FileUniqueName>0b77b0c0-68eb-4b9a-90ab-b477942171e7</FileUniqueName><Customer>Washoe</Customer><SubType>1</SubType><EventId>5bcce991-6f1a-4172-a235-a87f00d36c8f</EventId><EventName>IEP Notice of Reevaluation Meeting (2/7/2018)</EventName><FormId>0febcdfc-5d4d-4ca6-ab9e-a87f00d36c94</FormId><FormName>Notice of Meeting</FormName><StudentId>2507616</StudentId><StudentName>BREAKELL, NOAH</StudentName><StudentAutoId>40958</StudentAutoId><DistrictId>4</DistrictId></data>
 */
    
    
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }


}

