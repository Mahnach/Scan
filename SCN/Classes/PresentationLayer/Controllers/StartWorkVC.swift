//
//  StartWorkViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift

class StartWorkVC: UIViewController{

    @IBOutlet weak var clickPlusView: UIView!
    let realm = RealmService.realm
    var documents = [DocumentModel]()
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        clickPlusView.layer.cornerRadius = 20;
        clickPlusView.layer.masksToBounds = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        checkDocumentsToDisplay()
        if documents.count > 0 {
            RealmService.deleteLastDocument()
            pushPDFHistory()
        }
    }
    
    func checkDocumentsToDisplay() {
        if RealmService.getDocumentData().count > 0 {
            display()
        }
    }

    func display() {
        documents.removeAll()
        let allDocuments = realm.objects(DocumentModel.self)
        for each in allDocuments {
            if !each.isGenerated {
                break
            }
            let date = Date()
            let timeFromCreate = date.timeIntervalSince(each.date!)
            let timeFromCreateInt = Int(timeFromCreate)
            if RealmService.getDisplayTime()[0].displayTime < 0 {
                if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                    documents.append(each)
                }
            } else {
                if timeFromCreateInt < RealmService.getDisplayTime()[0].displayTime  {
                    if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                        documents.append(each)
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pushPDFHistory() {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
        self.navigationController?.pushViewController(PDFHistoryViewController, animated: false)
    }
    
    @IBAction func goToScanQRAction(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "loginWithQR")
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
        navigationController?.pushViewController(ScanQRViewController, animated: false)
    }
    
    @IBAction func goToSettingsAction(_ sender: UIButton) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let SettingsViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kSettingsViewController") as! SettingsVC
        navigationController?.pushViewController(SettingsViewController, animated: true)
    }
    
}
