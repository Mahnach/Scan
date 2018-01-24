//
//  PDFHistoryViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 17.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import PDFGenerator
import Alamofire
import RealmSwift

class PDFHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
  
    @IBOutlet weak var PDFTableView: UITableView!
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var documentPreview: UIImageView!
    
    var documents = [DocumentModel]()
    
    var PDFInstance: Results<DocumentModel>?
    var documentIndex = 0
    let realm = RealmService.realm
    var pdfFileURL: URL?
    fileprivate var outputAsData: Bool = true
    @IBOutlet weak var searchField: UITextField!
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        PDFTableView.delegate = self
        PDFTableView.dataSource = self
        searchInput.delegate = self
        self.hideKeyboardWhenTappedAround()
        PDFTableView.reloadData()
        searchField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        if documents.count > 0 {
            documents.removeAll()
        }
        queryDocuments()
        if documents.count == 0 {
            noDocumentsForUser()
        }
        PDFTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func queryDocuments() {

        let allDocuments = realm.objects(DocumentModel.self)
        for each in allDocuments {
            let date = Date()
            let timeFromCreate = date.timeIntervalSince(each.date!)
            let timeFromCreateInt = Int(timeFromCreate)

            if RealmService.getDisplayTime()[0].displayTime < 0 {
                if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                    self.documents.append(each)
                }
            } else {
                if timeFromCreateInt < RealmService.getDisplayTime()[0].displayTime  {
                    if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                        self.documents.append(each)
                    }
                }
            }
        }

        self.PDFTableView.reloadData()
    }

    @IBAction func changedTextField(_ sender: Any) {
        self.documents.removeAll()
        if (searchField.text?.count)! > 0 {
            self.documents.removeAll()
            let predicate = NSPredicate(format: "documentName CONTAINS [c] %@ AND userLogin LIKE [c] %@", searchField.text!, RealmService.getLoginModel()[0].login!)
            let filteredDocuments = realm.objects(DocumentModel.self).filter(predicate)
            PDFTableView.reloadData()
            for each in filteredDocuments {
                let date = Date()
                let timeFromCreate = date.timeIntervalSince(each.date!)
                let timeFromCreateInt = Int(timeFromCreate)
                
                if RealmService.getDisplayTime()[0].displayTime < 0 {
                    if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                        self.documents.append(each)
                    }
                } else {
                    if timeFromCreateInt < RealmService.getDisplayTime()[0].displayTime  {
                        if (each.userLogin! == RealmService.getLoginModel()[0].login) {
                            self.documents.append(each)
                        }
                    }
                }
                PDFTableView.reloadData()
            }
            
        } else {
            self.queryDocuments()
        }

    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFCell") as! PDFTableViewCell
        let documentPreviewImage = UIImage(data: (documents.reversed()[indexPath.section].imageArrayData.first?.imageData!)!)!
        cell.createData.text = String(describing: documents.reversed()[indexPath.section].createDate!)
        cell.documentPreview.image = documentPreviewImage
        let fileName = documents.reversed()[indexPath.section].documentName!
        cell.pdfName.text = fileName
        switch documents.reversed()[indexPath.section].status {
        case true:
                cell.statusImageView.image  = UIImage(named: "statusReady.png")
        case false:
            cell.statusImageView.image  = UIImage(named: "statusCancel.png")
        }

        cell.layer.cornerRadius = 15
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let removingCell = tableView.cellForRow(at: indexPath) as! PDFTableViewCell
            let removingName = removingCell.pdfName.text!
            let predicate = NSPredicate(format: "documentName LIKE [c] %@ AND userLogin LIKE [c] %@", removingName, RealmService.getLoginModel()[0].login!)
            let documentToRemove = realm.objects(DocumentModel.self).filter(predicate)
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this document?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Default action"), style: .`default`, handler: { _ in
                FileManager.default.clearTmpDirectory(documentName: removingName)
                try! self.realm.write {
                    self.realm.delete(documentToRemove[0].imageArrayData)
                    self.realm.delete(documentToRemove)
                }
                if self.documents.count > 0 {
                    self.documents.removeAll()
                    self.queryDocuments()
                    if self.documents.count == 0 {
                        self.noDocumentsForUser()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return documents.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        documentIndex = indexPath.section
        let choosenCell = tableView.cellForRow(at: indexPath) as! PDFTableViewCell
        let choosenName = choosenCell.pdfName.text!
        let predicate = NSPredicate(format: "documentName LIKE [c] %@ AND userLogin LIKE [c] %@", choosenName, RealmService.getLoginModel()[0].login!)
        let documentPage = realm.objects(DocumentModel.self).filter(predicate)

        PDFInstance = documentPage
        performSegue(withIdentifier: "PDFSegue", sender: self)
    }
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PDFSegue") {
            let viewController = segue.destination as! PDFReaderVC
            viewController.PDFInstance = PDFInstance
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func noDocumentsForUser() {
        let documentInstance = DocumentModel()
        let id = documentInstance.incrementID()
        documentInstance.userLogin = RealmService.getLoginModel()[0].login!
        documentInstance.id = id
        RealmService.writeIntoRealm(object: documentInstance)
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
        navigationController?.pushViewController(StartWorkViewController, animated: false)
    }
    
    @IBAction func addNewDocumentAction(_ sender: UIButton) {
        let documentInstance = DocumentModel()
        let id = documentInstance.incrementID()
        documentInstance.id = id
        documentInstance.userLogin = RealmService.getLoginModel()[0].login!
        RealmService.writeIntoRealm(object: documentInstance)
        
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
        navigationController?.pushViewController(ScanQRViewController, animated: false)
    }
    
    @IBAction func editAction(_ sender: UIButton) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let SettingsViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kSettingsViewController") as! SettingsVC
        SettingsViewController.pushFromHistory = true
        navigationController?.pushViewController(SettingsViewController, animated: true)
    }

}


