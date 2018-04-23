//
//  PhotoPreviewViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 16.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift
import PDFGenerator
import Alamofire
import Reachability

class PhotoPreviewVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var viewForScrollView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var uploadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var documentNameField: UITextField!
    @IBOutlet weak var pageCounterLabel: UILabel!
    //@IBOutlet weak var scrollView: UIScrollView!

    
    var pdfFileURL: URL?
    fileprivate var outputAsData: Bool = true
    let realm = RealmService.realm
    var isLandscape = 0
    var imagesArray = [UIImage]()
    var imageFromData: UIImage?
    var currentPage = 0
    let reachability = Reachability()!
    
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        collectionView.delegate = self
        view.isUserInteractionEnabled = true
        collectionView.dataSource = self
        uploadIndicator.stopAnimating()
        let fileName = RealmService.getDocumentData().last?.documentName!
        documentNameField.delegate = self
        documentNameField.text = fileName
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        let currentSession = CurrentSessionModel()
        currentSession.counter = 1
        RealmService.writeIntoRealm(object: currentSession)

        collectionView.setContentOffset(CGPoint(x: 1000, y: 0), animated: false)
        let pageCounter = String(describing: RealmService.getDocumentData().last!.imageArrayData.count)
        pageCounterLabel.text = pageCounter+" of "+pageCounter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        let index = IndexPath(item: RealmService.getDocumentData().last!.imageArrayData.count - 1, section: 0)
        collectionView.scrollToItem(at: index, at: UICollectionViewScrollPosition.right, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        let photoImage = UIImage(data:(RealmService.getDocumentData().last?.imageArrayData[indexPath.row].imageData!)!)
        cell.photoImageView.image = photoImage
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (RealmService.getDocumentData().last?.imageArrayData.count)!
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        let currentPageInt = Int(pageIndex) + 1
        currentPage = currentPageInt
        print(currentPage)
        let pageCounter = String(describing: RealmService.getDocumentData().last!.imageArrayData.count)
        pageCounterLabel.text = String(describing: currentPageInt)+" of "+pageCounter
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        editButton.isHidden = true
        saveButton.isHidden = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        editButton.isHidden = false
        saveButton.isHidden = true
    }
    
    func nameValidation(name: String) -> (String, Bool) {
        var documentName = name
        documentName = documentName.removingWhitespaces()
        if documentName.count == 0 {
            return ("", false)
        }
        if documentName == ".pdf" {
            return ("", false)
        }
        if documentName.suffix(4) == ".pdf" {
            return (documentName, true)
        } else {
            return (documentName+".pdf", true)
        }
    }
    
    @IBAction func saveNameAction(_ sender: UIButton) {
        let validationResult = nameValidation(name: documentNameField.text!)
        if !validationResult.1 {
            let alert = UIAlertController(title: "Warning", message: "Invalid document name.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
        } else {
            DocumentNameGenerator.generateDocumentName(changedName: validationResult.0, isChanged: true)
            documentNameField.text = validationResult.0
            documentNameField.resignFirstResponder()
            editButton.isHidden = false
            saveButton.isHidden = true
        }
    }
    
    @IBAction func changeNameAction(_ sender: UIButton) {
        documentNameField.becomeFirstResponder()
        editButton.isHidden = true
        saveButton.isHidden = false
    }
    
    @IBAction func addNextAction(_ sender: UIButton) {
        if (RealmService.getDocumentData().last?.imageArrayData.count)! > 14 {
            let alert = UIAlertController(title: "Warning", message: "Maximum 15 photos.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
        } else {
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let MakePhotoViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kMakePhotoViewController") as! MakePhotoVC
            navigationController?.pushViewController(MakePhotoViewController, animated: false)
        }

    }
    
    func getStringDateWithFormat() -> String {
        let date : Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        let todaysDate = dateFormatter.string(from: date)
        let todaysDateArray = todaysDate.components(separatedBy: ",")
        return todaysDateArray[0]+" "+todaysDateArray[1]
    }
    
    @IBAction func saveDocumentAction(_ sender: UIButton) {
        view.isUserInteractionEnabled = false
        if RealmService.getQRCode()[0].isValid {
            let alert = UIAlertController(title: "No internet Connection", message: "Document will be saved to PDF history.", preferredStyle: .alert)
            switch reachability.connection {
            case .none:
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                    self.dismiss(animated: true, completion: nil)
                    self.saveAndUpload(upload: false)
                }))
            default:
                self.dismiss(animated: true, completion: nil)
                self.saveAndUpload(upload: true)
            }
        } else {
            try! realm.write {
                realm.delete((RealmService.getDocumentData().last?.imageArrayData)!)
            }
            RealmService.deleteCurrentSession()
            noValidQR()
        }
    }
    
    func noValidQR()  {
        let alert = UIAlertController(title: "QR code is invalid for Accelify.", message: "Document cannot be sent using this code.", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            self.dismiss(animated: true, completion: nil)
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
            self.navigationController?.pushViewController(ScanQRViewController, animated: false)
        }))
    }
    
    func saveAndUpload(upload: Bool) {
        RealmService.deleteCurrentSession()
        uploadIndicator.startAnimating()
        
        let documentName = RealmService.getDocumentData().last?.documentName!
        var documentNameString = String(describing: documentName!)
        let documentWithOutDotPDF = documentNameString.dropLast(4)
        documentNameString = String(describing: documentWithOutDotPDF)
        documentNameString.append(String(describing: DocumentNameGenerator.currentDateWithSeconds())+".pdf")
        print(documentNameString)
        
        let dst = NSTemporaryDirectory().appending(documentNameString)
        var pages = [UIImage]()
        let existingObject = realm.object(ofType: DocumentModel.self, forPrimaryKey: RealmService.getDocumentData().last?.id)
        for image in (existingObject?.imageArrayData)! {
            let documentPhotoView = UIImage(data: image.imageData!)
            pages.append(documentPhotoView!)
        }
        if LoginModel.tokenIsValid() {
            do {
                print("GENERATED")
                try PDFGenerator.generate(pages, to: dst)
                try! realm.write {
                    existingObject?.isGenerated = true
                    let todaysDate = getStringDateWithFormat()
                    let dateNow = Date()
                    existingObject?.date = dateNow
                    existingObject?.createDate = todaysDate
                    existingObject?.documentName = documentNameString
                    realm.add(existingObject!, update: true)
                }
            } catch (_) {
                print("GENERATE ERROR")
            }
            if upload {
                sendPDF()
            } else {
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
                self.navigationController?.pushViewController(PDFHistoryViewController, animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Warning", message: "Session Expired.", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let LoginViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kLoginViewController") as! LoginVC
                self.navigationController?.pushViewController(LoginViewController, animated: true)
            }))
        }

    }
    func sendPDF() {
        PDFSendingRequest.sendPDF(resend: false, documentName: (RealmService.getDocumentData().last?.documentName!)!) { (completion, code) in
            if completion {
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
                self.navigationController?.pushViewController(PDFHistoryViewController, animated: true)
            } else {
                if code == 404 {
                    self.uploadIndicator.stopAnimating()
                    let alert = UIAlertController(title: "Server error", message: "Document will be saved to PDF history.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                        let PDFHistoryViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPDFHistoryViewController") as! PDFHistoryVC
                        self.navigationController?.pushViewController(PDFHistoryViewController, animated: true)
                    }))
                } else {
                    self.uploadIndicator.stopAnimating()
                    let alert = UIAlertController(title: "No internet Connection", message: "Document will be saved to PDF history.", preferredStyle: .alert)
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                        self.saveAndUpload(upload: false)
                    }))
                }
            }
        }
    }
    

    @IBAction func deleteDocumentAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Default action"), style: .`default`, handler: { _ in
            self.deletePage()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deletePage() {
        if (RealmService.getDocumentData().last!.imageArrayData.count > 0) {
            try! realm.write {
                if currentPage == 0 {
                    currentPage = 1
                }
                realm.delete((RealmService.getDocumentData().last?.imageArrayData[currentPage - 1])!)
            }
            if RealmService.getDocumentData().last!.imageArrayData.count > 0 {
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let PhotoPreviewViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kPhotoPreviewViewController") as! PhotoPreviewVC
                self.navigationController?.pushViewController(PhotoPreviewViewController, animated: false)
            } else {
                RealmService.deleteCurrentSession()
                
                let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let MakePhotoViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kMakePhotoViewController") as! MakePhotoVC
                navigationController?.pushViewController(MakePhotoViewController, animated: false)

            }
        }
    }

}

