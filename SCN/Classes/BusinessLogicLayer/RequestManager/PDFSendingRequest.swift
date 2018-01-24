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
import SWXMLHash

class PDFSendingRequest {
    
    static func sendPDF(resend: Bool, documentName: String, completion: @escaping (Bool, Int) -> Void) {
        let realm = RealmService.realm
        do {
            
            let tmp = URL(fileURLWithPath: NSTemporaryDirectory()+documentName)
            let fileData = try Data.init(contentsOf: tmp)
            let dataToUpload = fileData as NSData
            let pdfString = dataToUpload.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/Plan/Public/MobileAttachmentUpload"
            var eventId = "InvalidQR"
            
            let predicate = NSPredicate(format: "documentName LIKE [c] %@", documentName)
            let documentInstance = realm.objects(DocumentModel.self).filter(predicate)
            let xmlQR = SWXMLHash.parse(documentInstance.first!.qrCode!)
            let eventFromQR = (xmlQR["data"]["EventId"].element?.text)
            if (eventFromQR != nil) {
                eventId = eventFromQR!
            }

            var token = "INVALID_TOKEN"
            if LoginModel.tokenIsValid() {
                token = RealmService.getLoginModel()[0].token!
            }
            let parameters: Parameters = [
                "EventId": eventId,
                "AttachmentFileName": documentName,
                "Image": pdfString,
                "Token": token
            ]
            
            var headers = [String: String]()
            
            headers = [
                "Content-Type": "application/json"
            ]

            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON{ (response) in
                    let statusCode = response.response?.statusCode
                    print(statusCode)
                    if statusCode == 404 || statusCode == 1001 {
                        completion(false, 404)
                    }
                    if let _ = response.error {
                        completion(false, 404)
                    } else {
                        print(response.result.value)
                        if (response.result.value != nil) {
                            try! realm.write {
                                if (response.result.value as! String == "Ok") {
                                    documentInstance.first?.status = true
                                    realm.add(documentInstance.first!, update: true)
                                } else {
                                    documentInstance.first?.status = false
                                    realm.add(documentInstance.first!, update: true)
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



