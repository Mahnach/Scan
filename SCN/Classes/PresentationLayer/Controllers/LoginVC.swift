//
//  ViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift

class LoginVC: UIViewController, UITextFieldDelegate, UIDocumentPickerDelegate, UIPickerViewDelegate{
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var welcomeView: UIView!
    @IBOutlet weak var websiteInput: UITextField!
    @IBOutlet weak var userNameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    @IBOutlet weak var inputWebsiteView: UIView!
    @IBOutlet weak var inputUserNameView: UIView!
    @IBOutlet weak var inputPasswordView: UIView!
    @IBOutlet weak var dropDownLabel: UILabel!


    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        defaultSettings()
        welcomeView.layer.cornerRadius = 20
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        welcomeView.layer.masksToBounds = true
        inputWebsiteView?.layer.cornerRadius = 6
        inputUserNameView?.layer.cornerRadius = 6
        inputPasswordView?.layer.cornerRadius = 6
        activityIndicator.stopAnimating()
        websiteInput.attributedPlaceholder = setLetterSpacing(placeholder: websiteInput.placeholder!)
        userNameInput.attributedPlaceholder = setLetterSpacing(placeholder: userNameInput.placeholder!)
        passwordInput.attributedPlaceholder = setLetterSpacing(placeholder: passwordInput.placeholder!)
        
        if RealmService.getDocumentData().count > 0 {
            if (RealmService.getDocumentData().last?.imageArrayData.isEmpty)! || !(RealmService.getDocumentData().last?.isGenerated)! {
                RealmService.deleteLastDocument()
            }
        }
        if RealmService.getWebSiteModel().count > 0 {
            websiteInput.text = RealmService.getWebSiteModel().first?.websiteUrl!
        }
        if LoginModel.tokenIsValid() {
            pushCorrectController()
        }
        websiteInput.delegate = self
        userNameInput.delegate = self
        passwordInput.delegate = self

  
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setLetterSpacing(placeholder: String) -> NSMutableAttributedString {
        let text = placeholder
        let textRange = NSMakeRange(0, text.count)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: 1, range: textRange)
        return attributedString
    }
    
    func siteIsValid(siteName: String) -> Bool {
        var isValid = false
        switch siteName {
        case "dc-demo.accelidemo.com":
            isValid = true
            break
        case "washoe-demo.accelidemo.com":
            isValid = true
            break
        case "dc.acceliplan.com":
            isValid = true
            break
        case "hampton.acceliplan.com":
            isValid = true
            break
        case "dade-demo.accelidemo.com":
            isValid = true
            break
        case "washoe.acceliplan.com":
            isValid = true
            break
        case "washoe.acceliqc.com":
            isValid = true
            break
        default:
            isValid = false
            break
        }
        return isValid
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        activityIndicator.startAnimating()
        let siteName = websiteInput.text
        if (websiteInput.text?.isEmpty)! || (userNameInput.text?.isEmpty)! || (passwordInput.text?.isEmpty)! {
            activityIndicator.stopAnimating()
            popupWarning(titleMessage: "Warning", describing: "All fields are required")
        } else {
            let isValid = siteIsValid(siteName: siteName!)
            if isValid {
                RealmService.deleteWebsite()
                let webSiteInstance = WebSiteModel()
                webSiteInstance.websiteUrl = websiteInput.text!
                RealmService.writeIntoRealm(object: webSiteInstance)
                LoginRequest.loginRequest(login: userNameInput.text!, password: passwordInput.text!){ (completion, code) in
                    switch completion {
                    case true:
                        self.pushCorrectController()
                        break
                    case false:
                        if code == 404 {
                            self.activityIndicator.stopAnimating()
                            self.popupWarning(titleMessage: "Server error", describing: "Please, try again later.")
                        } else {
                            self.activityIndicator.stopAnimating()
                            self.popupWarning(titleMessage: "Warning", describing: "User not found.")
                        }
                        break
                    }
                }
            } else {
                activityIndicator.stopAnimating()
                popupWarning(titleMessage: "Warning", describing: "Website is incorrect")
            }
        }
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
            RealmService.writeIntoRealm(object: documentInstance)
            
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
            navigationController?.pushViewController(StartWorkViewController, animated: false)
        }
    }
    
    func defaultSettings() {
        let displayTimeInstance = DisplayTimeModel()
        displayTimeInstance.displayTime = 259200
        RealmService.writeIntoRealm(object: displayTimeInstance)
    }
    
    func popupWarning(titleMessage: String, describing: String) {
        let alert = UIAlertController(title: titleMessage, message: describing, preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
    }
}
