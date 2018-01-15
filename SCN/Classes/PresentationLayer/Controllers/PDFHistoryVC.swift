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
    
    
    var documentIndex = 0
    let realm = try! Realm()
    var pdfFileURL: URL?
    fileprivate var outputAsData: Bool = true
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        PDFTableView.delegate = self
        PDFTableView.dataSource = self
        searchInput.delegate = self
        self.hideKeyboardWhenTappedAround()
        PDFTableView.reloadData()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        PDFTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PDFCell") as! PDFTableViewCell
        let documentPreviewImage = UIImage(data: (RealmService.getDocumentData().reversed()[indexPath.section].imageArrayData.first?.imageData!)!)!
        cell.createData.text = String(describing: RealmService.getDocumentData().reversed()[indexPath.section].createDate!)
        cell.documentPreview.image = documentPreviewImage
        var fileName = RealmService.getDocumentData().reversed()[indexPath.section].documentName!
        if fileName.count > 30 {
            let index = fileName.index(fileName.startIndex, offsetBy: 30)
            fileName = String(fileName.prefix(upTo: index))+"..pdf"
        }
        cell.pdfName.text = fileName
        switch RealmService.getDocumentData().reversed()[indexPath.section].status {
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
            
            let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this document?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Default action"), style: .`default`, handler: { _ in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Default action"), style: .`default`, handler: { _ in
                let documentName = RealmService.getDocumentData().reversed()[indexPath.section].documentName!
                FileManager.default.clearTmpDirectory(documentName: documentName)
                let PDFInstance = self.realm.objects(DocumentModel.self).filter("documentName = '"+documentName+"'")
                try! self.realm.write {
                    self.realm.delete((RealmService.getDocumentData().reversed()[indexPath.section].imageArrayData))
                    self.realm.delete(PDFInstance)
                }
                tableView.reloadData()
                if RealmService.getDocumentData().count == 0 {
                    let documentInstance = DocumentModel()
                    let id = documentInstance.incrementID()
                    documentInstance.id = id
                    RealmService.writeIntoRealm(object: documentInstance)
                    
                    let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
                    self.navigationController?.pushViewController(StartWorkViewController, animated: false)
                    
                }
            }))
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    // MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return RealmService.getDocumentData().count
    }
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        documentIndex = indexPath.section
        performSegue(withIdentifier: "PDFSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PDFSegue") {
            let viewController = segue.destination as! PDFReaderVC
            viewController.documentIndex = documentIndex
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let date = Date()
        let timeFromCreate = date.timeIntervalSince(RealmService.getDocumentData().reversed()[indexPath.section].date!)
        let timeFromCreateInt = Int(timeFromCreate)
        if RealmService.getDisplayTime()[0].displayTime < 0 {
            return 100
        }
        if timeFromCreateInt > RealmService.getDisplayTime()[0].displayTime  {
            return 0
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25;
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
    
    @IBAction func addNewDocumentAction(_ sender: UIButton) {
        let documentInstance = DocumentModel()
        let id = documentInstance.incrementID()
        documentInstance.id = id
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

