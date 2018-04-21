//
//  StepOneViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 17.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import QRCodeReader
import AVFoundation
import RealmSwift
import SWXMLHash

class ScanQRVC: UIViewController, QRCodeReaderViewControllerDelegate {

    @IBOutlet weak var stepOneView: UIView!
    let realm = RealmService.realm
    let isQRLogin = UserDefaults.standard.bool(forKey: "loginWithQR")
    lazy var reader: QRCodeReader = QRCodeReader()
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
        }
        return QRCodeReaderViewController(builder: builder)
    }()

    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()

        RealmService.deleteQRCode()
        scanQR()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    func pushCorrectController() {
        if RealmService.getDocumentData().count != 0{
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
            navigationController?.pushViewController(PDFHistoryViewController, animated: false)
        } else {
            let documentInstance = DocumentModel()
            let id = documentInstance.incrementID()
            documentInstance.id = id
            documentInstance.userLogin = RealmService.getLoginModel()[0].login!
            RealmService.writeIntoRealm(object: documentInstance)
            
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
            navigationController?.pushViewController(StartWorkViewController, animated: false)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        if isQRLogin {
            pushLoginController(loadingWhileLogin: true)
        } else {
            let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)
            try! realm.write {
                existingObject?.qrCode = RealmService.getQRCode().last!.qrCode
                realm.add(existingObject!, update: true)
            }
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let ScanDocumentViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanDocumentViewController") as! ScanDocumentVC
            navigationController?.pushViewController(ScanDocumentViewController, animated: false)
        }
    }
    
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        if isQRLogin {
            if LoginModel.tokenIsValid() {
                pushCorrectController()
            } else {
                pushLoginController(loadingWhileLogin: false)
            }
        } else {
            if RealmService.getDocumentData().count != 0 {
                if let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id) {
                    try! realm.write {
                        realm.delete(existingObject)
                    }
                }
                pushCorrectController()
            }
        }
//        
//        if RealmService.getDocumentData().count != 0 {
//            if let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id) {
//                try! realm.write {
//                    realm.delete(existingObject)
//                }
//            }
//            if isQRLogin {
//                if LoginModel.tokenIsValid() {
//                    pushCorrectController()
//                } else {
//                    pushLoginController(loadingWhileLogin: false)
//                }
//            }
//            
//            pushCorrectController()
//            
//        } else {
//            if isQRLogin {
//                pushLoginController(loadingWhileLogin: false)
//            } else {
//                pushStartWorkController()
//            }
//        }
    }
    
    func scanQR() {
        readerVC.delegate = self
        readerVC.view.backgroundColor = UIColor(red: 231/255, green: 244/255, blue: 246/255, alpha: 1.0)
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            if (result?.value != nil) {
                print(result!.value)
                let xmlQR = SWXMLHash.parse(result!.value)
                
                if self.isQRLogin {
                    RealmService.deleteQRLogin()
                    let qrLoginInstance = QRLoginModel()
                    
                    qrLoginInstance.qrCode = result!.value
                    qrLoginInstance.customer = xmlQR["data"]["Customer"].element?.text
                    qrLoginInstance.login = xmlQR["data"]["UserName"].element?.text.fromBase64()
                    qrLoginInstance.password = xmlQR["data"]["Password"].element?.text.fromBase64()
                    //qrLoginInstance.site = xmlQR["data"]["SiteName"].element?.text
                    if let _ = xmlQR["data"]["UserName"].element?.text {
                        qrLoginInstance.isValid = true
                    }
                    if let _ = xmlQR["data"]["Password"].element?.text {
                        qrLoginInstance.isValid = true
                    }
                    print(qrLoginInstance.login)
                    print(qrLoginInstance.password)
                    RealmService.writeIntoRealm(object: qrLoginInstance)
                } else {
                    RealmService.deleteQRCode()
                    let qrInstance = QRCodeModel()
                    
                    qrInstance.qrCode = result!.value
                    qrInstance.eventName = xmlQR["data"]["EventName"].element?.text
                    qrInstance.formName = xmlQR["data"]["FormName"].element?.text
                    qrInstance.studentName = xmlQR["data"]["StudentName"].element?.text
                    qrInstance.studentId = xmlQR["data"]["StudentId"].element?.text
                    qrInstance.eventId = xmlQR["data"]["EventId"].element?.text
                    qrInstance.customer = xmlQR["data"]["Customer"].element?.text
                    qrInstance.fileUniqueName = xmlQR["data"]["FileUniqueName"].element?.text
                    qrInstance.programType = xmlQR["data"]["ProgramType"].element?.text
                    if let _ = xmlQR["data"]["FileUniqueName"].element?.text {
                        qrInstance.isValid = true
                    }
                    if let _ = xmlQR["data"]["EventId"].element?.text {
                        qrInstance.isValid = true
                    }
                    if let _ = xmlQR["data"]["ProgramType"].element?.text {
                        qrInstance.isValid = true
                    }
                    RealmService.writeIntoRealm(object: qrInstance)
                }
            }
        }
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            print("Access is allowed")
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    print("Access is allowed")
                } else {
                    let alert = UIAlertController(title: "Camera Check", message: "Access to the camera has been prohibited. Please enable it in the Settings app to continue.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                        if self.isQRLogin {
                            self.pushLoginController(loadingWhileLogin: false)
                        } else {
                            self.pushStartWorkController()
                        }
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        readerVC.modalPresentationStyle = .formSheet
        readerVC.navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.pushViewController(readerVC, animated: true)
    }
    
    func pushStartWorkController() {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
        navigationController?.pushViewController(StartWorkViewController, animated: false)
    }
    
    func pushLoginController(loadingWhileLogin: Bool) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let LoginViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kLoginViewController") as! LoginVC
        LoginViewController.loadingWhileLogin = loadingWhileLogin
        self.navigationController?.pushViewController(LoginViewController, animated: false)
    }

}
