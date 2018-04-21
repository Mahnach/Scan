//
//  RealmDataManager.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift
import Security

class RealmService {

    static var realm: Realm = {
        let configuration = Realm.Configuration(encryptionKey: getKey() as Data, schemaVersion: 5, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                //add QRCodeModel.fileUniqueName (v1)
                //add QRCodeModel.programType (v2)
                //add SettingsSitesModel.isDefault (v3)
                //add LoginModel.tokenType (v4)
                //add QRLoginModel (v5)
            } //3b1435ca73930b1ef06928a3b9926f4328c586d4156bb4e26239282f00580dac78578e6db9dbd9f6bba6e319e73a1b41df6e7ab9233f2a9757a9523ff57328f8
        })
        let realm: Realm
        do {
            realm = try Realm(configuration: configuration)
            
        } catch {
            print(error.localizedDescription)
            return try! Realm()
        }
        return realm
    }()

    static func getKey() -> NSData {
        let keychainIdentifier = "io.Realm.EncryptionExampleKey"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        var query: [NSString: AnyObject] = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecReturnData: true as AnyObject
        ]

        var dataTypeRef: AnyObject?
        var status = withUnsafeMutablePointer(to: &dataTypeRef) { SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0)) }
        if status == errSecSuccess {
            return dataTypeRef as! NSData
        }
        
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        
        query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: keychainIdentifierData as AnyObject,
            kSecAttrKeySizeInBits: 512 as AnyObject,
            kSecValueData: keyData
        ]
        
        status = SecItemAdd(query as CFDictionary, nil)
        assert(status == errSecSuccess, "Failed to insert the new key in the keychain")
        
        return keyData
    }
    
    
    // MARK: Write
    static func writeIntoRealm(object: Object) {
        try! realm.write {
            realm.add(object)
        }
    }
    
    // MARK: Get
    static func getQRLoginData() -> Results<QRLoginModel> {
        let data = realm.objects(QRLoginModel.self)
        return data
    }
    
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
    static func getDefaultUserName() -> Results<DefaultUserNameModel> {
        let data = realm.objects(DefaultUserNameModel.self)
        return data
    }
    
    // MARK: Delete
    static func deleteQRLogin() {
        if RealmService.getQRLoginData().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getQRLoginData())
            }
        }
    }
    
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
    static func deleteDefaultUserName() {
        if RealmService.getDefaultUserName().count > 0 {
            try! realm.write {
                realm.delete(RealmService.getDefaultUserName())
            }
        }
    }
    

}

