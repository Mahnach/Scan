//
//  PDFReaderViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 05.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability


class PDFReaderVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    let realm = RealmService.realm
    
    @IBOutlet weak var documentName: UILabel!
    @IBOutlet weak var resendIndicator: UIActivityIndicatorView!
    @IBOutlet weak var sendButton: UIButton!
    
    var documentIndex = 0
    var PDFInstance: Results<DocumentModel>?
    let reachability = Reachability()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.isHidden = true
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        resendIndicator.stopAnimating()
        resendIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        collectionView.delegate = self
        collectionView.dataSource = self

        documentName.text = PDFInstance?.first?.documentName!
        if PDFInstance?.first?.status == false {
            sendAgain()
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
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

    @IBAction func backToPreviousAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func sendAgain() {
        let alert = UIAlertController(title: "No internet Connection", message: "Please try again later.", preferredStyle: .alert)
        switch reachability.connection {
        case .none:
            self.present(alert, animated: true, completion: nil)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
        default:
            self.dismiss(animated: true, completion: nil)
            self.resendPDF()
        }
    }
    
    func resendPDF() {
        if LoginModel.tokenIsValid() {
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
        } else {
            tokenValidation()
        }
    }

    func tokenValidation() {
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
