//
//  RequestManager.swift
//  SCN
//
//  Created by BAMFAdmin on 03.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

class PDFSendingRequest {
    
    static func sendPDF(resend: Bool, documentName: String, completion: @escaping (Bool, Int) -> Void) {
        let realm = try! Realm()
        do {
            
            let tmp = URL(fileURLWithPath: NSTemporaryDirectory()+documentName)
            let fileData = try Data.init(contentsOf: tmp)
            let dataToUpload = fileData as NSData
            let pdfString = dataToUpload.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/Plan/Public/MobileAttachmentUpload"
            let eventId: String?
            if (RealmService.getQRCode()[0].eventId == nil) {
                eventId = "InvalidQR"
            } else {
                eventId = RealmService.getQRCode()[0].eventId!
            }
            let parameters: Parameters = [
                "EventId": eventId!,
                "AttachmentFileName": RealmService.getDocumentData().last!.documentName!,
                "Image": pdfString,
                "Token": RealmService.getLoginModel()[0].token!
            ]
            
            var headers = [String: String]()
            
            headers = [
                "Content-Type": "application/json"
            ]
            let existingDocumentInstance = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)

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
                            try! realm.write {
                                if (response.result.value as! String == "Ok") {
                                    existingDocumentInstance?.status = true
                                    realm.add(existingDocumentInstance!, update: true)
                                } else {
                                    existingDocumentInstance?.status = false 
                                    realm.add(existingDocumentInstance!, update: true)
                                }
                                completion(true, 0)
                            }
                        }
                    }
            }
        } catch {
            print("Error")
        }
    }
}



