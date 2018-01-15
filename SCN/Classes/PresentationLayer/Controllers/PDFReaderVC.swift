//
//  PDFReaderViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 05.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift

class PDFReaderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    let realm = try! Realm()
    
    @IBOutlet weak var resendIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendButton: UIButton!
    var documentIndex = 0
    
    var PDFInstance: Results<DocumentModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isHidden = true
        //        let pdfFileURL = URL(fileURLWithPath: NSTemporaryDirectory()+fileName)
        var fileName = RealmService.getDocumentData().reversed()[documentIndex].documentName!
        PDFInstance = realm.objects(DocumentModel.self).filter("documentName = '"+fileName+"'")
        resendIndicator.stopAnimating()
        resendIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        collectionView.delegate = self
        collectionView.dataSource = self
        if fileName.count > 30 {
            let index = fileName.index(fileName.startIndex, offsetBy: 25)
            fileName = String(fileName.prefix(upTo: index))+"....pdf"
        }
        navigationItem.title = fileName
        
        if PDFInstance?.first?.status == false {
            sendAgain()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        let photoImage = UIImage(data:(PDFInstance?.first?.imageArrayData[indexPath.row].imageData!)!)
        cell.photoImageView.image = photoImage
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (PDFInstance?.first?.imageArrayData.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(collectionView.frame.size)
        return collectionView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    
    func sendAgain() {
        let alert = UIAlertController(title: "Confirmation", message: "Resend PDF to AcceliPLAN?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"), style: .`default`, handler: { _ in
        self.resendIndicator.startAnimating()
            PDFSendingRequest.sendPDF(resend: true, documentName: (self.PDFInstance?.first?.documentName!)!){ (completion, code) in
                if completion {
                    let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
                    self.navigationController?.pushViewController(PDFHistoryViewController, animated: true)
                } else {
                    if code == 404 {
                        self.resendIndicator.stopAnimating()
                        let alert = UIAlertController(title: "Server error", message: "Please, try again later.", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                    } else {
                        self.resendIndicator.stopAnimating()
                        let alert = UIAlertController(title: "No internet Connection", message: "Make sure your device is connected to the internet.", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Default action"), style: .`default`, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

}
