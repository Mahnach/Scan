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
    
    let realm = RealmService.realm
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(RealmService.getQRCode().last?.isValid)! {
            let alert = UIAlertController(title: "WARNING", message: "QR code is invalid for Accelify", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                DocumentNameGenerator.generateDocumentName(changedName: "", isChanged: false)
                self.dismiss(animated: true, completion: nil)
                self.pushScanDocumentController()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            if !siteEqualToQR() {
                let alert = UIAlertController(title: "WARNING", message: "QR code is invalid for this website", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
                    self.navigationController?.pushViewController(ScanQRViewController, animated: false)
                }))
                self.present(alert, animated: true, completion: nil)
            } else {
                DocumentNameGenerator.generateDocumentName(changedName: "", isChanged: false)
                let alert = UIAlertController(title: "Valid QR Code", message: RealmService.getDocumentData().last?.documentName! , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    self.pushScanDocumentController()
                }))
                self.present(alert, animated: true, completion: nil)
           }
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
    
    func siteEqualToQR() -> Bool {
        var siteUrl = ""
        if RealmService.getQRLoginData().count > 0 {
            siteUrl = "http://dade-demo.accelidemo.com"
        } else {
            siteUrl = RealmService.getWebSiteModel()[0].websiteUrl!
        }

        var validationString = siteUrl.components(separatedBy: "-")
        if validationString.count == 1 {
            validationString = (validationString.first?.components(separatedBy: "."))!
        }
        if var customer =  RealmService.getQRCode()[0].customer {
            if customer == "Miami" {
                customer = "Dade"
            }

            let siteFromLogin = validationString.first!.components(separatedBy: "//")
            print(customer.lowercased())
            print(siteFromLogin[1].lowercased())
            if customer.lowercased() == siteFromLogin[1].lowercased() {
                return true
            } else {
                return false
            }
        } else {
            return false
        }

    }

}
