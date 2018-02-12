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
    
    static let realm = RealmService.realm
    
    enum SendingType {
        case eventId, student, distribution, oldEventId
    }
    
    static func getSendingAddress(documentName: String, xmlQR: XMLIndexer) -> (String, [String: Any]) {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory()+documentName)
        let fileData = try! Data.init(contentsOf: tmp)
        let dataToUpload = fileData as NSData
        let pdfString = dataToUpload.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        var address = SendingType.eventId
        if let _ = (xmlQR["data"]["EventId"].element?.text) {
            address = .eventId
        }
        if let _ = (xmlQR["data"]["ProgramType"].element?.text) {
            address = .student
        }
        if let _ = (xmlQR["data"]["FileUniqueName"].element?.text) {
            address = .distribution
        }
        let url: String?
        let parameters: [String: Any]?
        
        //address = .oldEventId // MANUAL CHOICE
        
        switch address {
            
        case .eventId:
            url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/PLAN/api/mobile/eventattachmentupload"
            parameters = [
                "EventId": (xmlQR["data"]["EventId"].element?.text)!,
                "AttachmentFileName": documentName,
                "Image": pdfString
            ]
            print("event")
        case .student:
            url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/PLAN/api/mobile/studentattachmentupload"
            parameters = [
                "CommonStudentId": (xmlQR["data"]["StudentAutoId"].element?.text)!,
                "ProgramType": (xmlQR["data"]["ProgramType"].element?.text)!,
                "AttachmentFileName": documentName,
                "Image": pdfString
            ]
            print("student")
        case .distribution:
            url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/PLAN/api/mobile/parentresponseattachmentupload"
            parameters = [
                "FileUniqueName": (xmlQR["data"]["FileUniqueName"].element?.text)!,
                "AttachmentFileName": documentName,
                "Image": pdfString
            ]
            print("distribution")
            
        case .oldEventId:
            url = "http://"+RealmService.getWebSiteModel()[0].websiteUrl!+"/Plan/Public/MobileAttachmentUpload"
            parameters = [
                "EventId": (xmlQR["data"]["EventId"].element?.text)!,
                "AttachmentFileName": documentName,
                "Image": pdfString
            ]
            print("oldEventId")
        }
        return (url!, parameters!)
    }
    
    
    static func sendPDF(resend: Bool, documentName: String, completion: @escaping (Bool, Int) -> Void) {

            let predicate = NSPredicate(format: "documentName LIKE [c] %@", documentName)
            let documentInstance = realm.objects(DocumentModel.self).filter(predicate)
            let xmlQR = SWXMLHash.parse(documentInstance.first!.qrCode!)
            let getRequestData = getSendingAddress(documentName: documentName, xmlQR: xmlQR)
            var headers = [String: String]()
        
            var token = "INVALID_TOKEN"
            var tokenType = "INVALID_TOKEN_TYPE"
            if LoginModel.tokenIsValid() {
                token = RealmService.getLoginModel()[0].token!
                tokenType = RealmService.getLoginModel()[0].tokenType!+" "+token
            }
            print(tokenType)
            headers = [
                "Content-Type": "application/json",
                "Authorization": tokenType
            ]
        
            Alamofire.request(getRequestData.0, method: .post, parameters: getRequestData.1, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .responseJSON{ (response) in
                    print(response.result.value)
                    let statusCode = response.response?.statusCode
                    print(statusCode)
                    if statusCode == 404 || statusCode == 1001 {
                        completion(false, 404)
                    }
                    if let _ = response.error {
                        completion(false, 404)
                    } else {
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
    }
}

