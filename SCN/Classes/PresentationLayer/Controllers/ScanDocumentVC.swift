//
//  StepTwoViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 17.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import PDFGenerator
import RealmSwift

class ScanDocumentVC: UIViewController {

    @IBOutlet weak var stepTwoView: UIView!
    @IBOutlet weak var documentNameLabel: UILabel!
    
    let realm = try! Realm()
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !(RealmService.getQRCode().last?.isValid)! {
            let alert = UIAlertController(title: "WARNING", message: "QR code is invalid for Accelify", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.generateDocumentName()
                self.dismiss(animated: true, completion: nil)
                self.pushScanDocumentController()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.generateDocumentName()
            let alert = UIAlertController(title: "Valid QR Code", message: RealmService.getDocumentData().last?.documentName! , preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
                self.pushScanDocumentController()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pushScanDocumentController() {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let MakePhotoViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kMakePhotoViewController") as! MakePhotoVC
        navigationController?.pushViewController(MakePhotoViewController, animated: false)
    }

    
    func generateDocumentName() {
        let existingDocumentInstance = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)
        var documentCount = 0
        var documentIsExist = true
        var documentName = "InvalidQRCode.pdf"
        if (RealmService.getQRCode().last?.isValid)! {
            documentName = parsingDocumentNameFromQR()
        }
        while documentIsExist{
            let PDFInstance = realm.objects(DocumentModel.self).filter("documentName = '"+documentName+"'")
            if PDFInstance.count == 0 {
                documentIsExist = false
                break
            } else {
                documentCount += 1
                if (documentCount > 1) {
                    let start = documentName.startIndex
                    var end = documentName.index(documentName.startIndex, offsetBy: 2)
                    if documentCount >= 11 {
                            end = documentName.index(documentName.startIndex, offsetBy: 3)
                    }
                    print(documentCount)
                    documentName = documentName.replacingCharacters(in: start..<end, with: "("+String(documentCount))
                } else {
                    documentName = "("+String(documentCount)+")"+documentName
                }
            }
        }
        
        try! realm.write {
            existingDocumentInstance?.documentName = documentName
            realm.add(existingDocumentInstance!, update: true)
        }
    }
    
    func parsingDocumentNameFromQR() -> String {
        let studentNameFromQR = RealmService.getQRCode()[0].studentName!
        let parsedStudentNameArray = studentNameFromQR.components(separatedBy: ",")
        let firstInitialName = parsedStudentNameArray[1]
        let index = firstInitialName.index(firstInitialName.startIndex, offsetBy: 1)
        let firstParsedName = String(describing: firstInitialName[index])
        let parsedFullName = firstParsedName+"."+parsedStudentNameArray[0]
        
        let studentIdFromQR = RealmService.getQRCode()[0].studentId!
        let parsedStudentId = "_"+studentIdFromQR
        
        let eventNameFromQR = RealmService.getQRCode()[0].eventName!
        let eventNameWOWhitespaces = eventNameFromQR.removingWhitespaces()
        let parsedEventNameArray = eventNameWOWhitespaces.components(separatedBy: "(")
        let parsedEventName = "_"+parsedEventNameArray[0]

        
        let finalPDFName = parsedFullName + parsedStudentId + parsedEventName+".pdf"
        
        return finalPDFName
    }

}
