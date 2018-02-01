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
        let configuration = Realm.Configuration(encryptionKey: getKey() as Data, schemaVersion: 2, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
                //add QRCodeModel.fileUniqueName (v1)
                //add QRCodeModel.programType (v2)
                //fb1dc06d870174e5a87ceb30122c6a7a14094bcbbec3882993f40fe266d8c23d744ab5547d7b74d1d5064e2df7d08e8d3781b5a96db1dc02bef9668e8cde05f2
            }
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
        // Identifier for our keychain entry - should be unique for your application
        let keychainIdentifier = "io.Realm.EncryptionExampleKey"
        let keychainIdentifierData = keychainIdentifier.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        // First check in the keychain for an existing key
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
        
        // No pre-existing key from this application, so generate a new one
        let keyData = NSMutableData(length: 64)!
        let result = SecRandomCopyBytes(kSecRandomDefault, 64, keyData.mutableBytes.bindMemory(to: UInt8.self, capacity: 64))
        assert(result == 0, "Failed to get random bytes")
        
        // Store the key in the keychain
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

