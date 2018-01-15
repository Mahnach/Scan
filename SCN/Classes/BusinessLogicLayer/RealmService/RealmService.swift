//
//  RealmDataManager.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmService {
    
    static let realm = try! Realm()
    
    // MARK: Write
    static func writeIntoRealm(object: Object) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(object)
        }
    }
    
    // MARK: Get
    static func getCounterFromCurrentSession() -> Results<CurrentSessionModel> {
        let data = realm.objects(CurrentSessionModel.self)
        return data
    }
    
    static func getQRCode() -> Results<QRCodeModel> {
        let data = realm.objects(QRCodeModel.self)
        return data
    }
    
    static func getPhotoData() -> Results<ImageModel> {
        let data = realm.objects(ImageModel.self)
        return data
    }
    
    static func getDocumentData() -> Results<DocumentModel> {
        let data = realm.objects(DocumentModel.self)
        return data
    }
    static func getWebSiteModel() -> Results<WebSiteModel> {
        let data = realm.objects(WebSiteModel.self)
        return data
    }
    static func getLoginModel() -> Results<LoginModel> {
        let data = realm.objects(LoginModel.self)
        return data
    }
    static func getDisplayTime() -> Results<DisplayTimeModel> {
        let data = realm.objects(DisplayTimeModel.self)
        return data
    }
    static func getSettingsSitesModel() -> Results<SettingsSitesModel> {
        let data = realm.objects(SettingsSitesModel.self)
        return data
    }
    
    // MARK: Delete
    static func deleteQRCode() {
        if RealmService.getQRCode().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getQRCode())
            }
        }
    }
    
    static func deleteCurrentSession() {
        if RealmService.getCounterFromCurrentSession().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getCounterFromCurrentSession())
            }
        }
    }
    
    static func deleteImageData() {
        if RealmService.getPhotoData().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getPhotoData())
            }
        }
    }
    
    static func deleteDocument() {
        if RealmService.getDocumentData().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getDocumentData())
            }
        }
    }
    
    static func deleteLastDocument() {
        if RealmService.getDocumentData().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getDocumentData().last!)
            }
        }
    }
    static func deleteWebsite() {
        if RealmService.getWebSiteModel().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getWebSiteModel())
            }
        }
    }
    static func deleteLoginData() {
        if RealmService.getLoginModel().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getLoginModel())
            }
        }
    }
    static func deleteDisplayTime() {
        if RealmService.getDisplayTime().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getDisplayTime())
            }
        }
    }
    static func deleteSettingsSites() {
        if RealmService.getSettingsSitesModel().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getSettingsSitesModel())
            }
        }
    }
    

}

