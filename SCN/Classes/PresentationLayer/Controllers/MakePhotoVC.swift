//
//  PhotoViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 15.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift
import IRLDocumentScanner

class MakePhotoVC: UIViewController, IRLScannerViewControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let realm = RealmService.realm
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
            self.activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
            let scanner = IRLScannerViewController.standardCameraView(with: self)
            scanner.showControls = true
            scanner.showAutoFocusWhiteRectangle = true
            self.present(scanner, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageSnapped(_ page_image: UIImage, from controller: IRLScannerViewController) {
        controller.dismiss(animated: true) { () -> Void in

            let capturedImageData: Data = UIImageJPEGRepresentation(page_image, 0.0)!
            let documentInstance = DocumentModel()
            let imageInstance = ImageModel()
            
            imageInstance.imageData = capturedImageData
            
            if let existingObject = self.realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id) {
                try! self.realm.write {
                    existingObject.imageArrayData.append(imageInstance)
                    self.realm.add(existingObject, update: true)
                }
            } else {
                documentInstance.imageArrayData.append(imageInstance)
                RealmService.writeIntoRealm(object: imageInstance)
                RealmService.writeIntoRealm(object: documentInstance)
            }
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let PhotoPreviewViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPhotoPreviewViewController") as! PhotoPreviewVC
            self.navigationController?.pushViewController(PhotoPreviewViewController, animated: false)
        }
    }
    
    func didCancel(_ cameraView: IRLScannerViewController) {
        cameraView.dismiss(animated: true) {}
        print("CANCEL")
        if RealmService.getCounterFromCurrentSession().count > 0 {
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let PhotoPreviewViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPhotoPreviewViewController") as! PhotoPreviewVC
            self.navigationController?.pushViewController(PhotoPreviewViewController, animated: false)
        } else {
            if RealmService.getDocumentData().count > 0 {
                if let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id) {
                    try! realm.write {
                        realm.delete(existingObject)
                    }
                }
                if RealmService.getDocumentData().count > 0 {
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
            } else {
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
                navigationController?.pushViewController(StartWorkViewController, animated: false)
            }
        }
    }

}
