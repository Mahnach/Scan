//
//  ViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability
import Crashlytics
import Firebase

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
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginWithQRButton: UIButton!
    
    var sitesList = [String]()
    var ref: DatabaseReference!
    let reachability = Reachability()!
    let realm = RealmService.realm
    let yourAttributes : [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
        NSAttributedStringKey.foregroundColor : UIColor(red: 171 / 255.0, green: 188 / 255.0, blue: 210 / 255.0, alpha: 1.0),
        NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
    
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFromFirebase()
        setupUI()
        preparingApplication()
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
    
    func setupUI() {
        self.hideKeyboardWhenTappedAround()
        view.isUserInteractionEnabled = true
        welcomeView.layer.cornerRadius = 20
        logoImageView.layer.cornerRadius = 15
        logoImageView.layer.masksToBounds = true
        activityIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        welcomeView.layer.masksToBounds = true
        inputWebsiteView?.layer.cornerRadius = 6
        inputUserNameView?.layer.cornerRadius = 6
        inputPasswordView?.layer.cornerRadius = 6
        activityIndicator.stopAnimating()
        websiteInput.attributedPlaceholder = setLetterSpacing(placeholder: websiteInput.placeholder!)
        userNameInput.attributedPlaceholder = setLetterSpacing(placeholder: userNameInput.placeholder!)
        passwordInput.attributedPlaceholder = setLetterSpacing(placeholder: passwordInput.placeholder!)
        
        let attributeString = NSMutableAttributedString(string: "Login with QR code",
                                                        attributes: yourAttributes)
        loginWithQRButton.setAttributedTitle(attributeString, for: .normal)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        websiteInput.delegate = self
        userNameInput.delegate = self
        passwordInput.delegate = self
    }
    
    func fetchFromFirebase() {
        ref = Database.database().reference()
        ref.observeSingleEvent(of: .value) { (snapshot) in
            let value = snapshot.value as! [String: Any]
            let parsedSitesList = value["sites"] as! [[String: Any]]
            let parsedLogoutList = value["auto_logout"] as! [[String: Any]]
            let parsedSecurityList = value["content_enable"] as! [[String: Any]]
            
            for element in parsedSitesList {
                self.sitesList.append(element["url"] as! String)
            }
            guard let timeForLogout = parsedLogoutList[0]["time_in_minutes"] as? String else {
                return
            }
            guard let contentEnable = parsedSecurityList[0]["value"] as? String else {
                return
            }
            let timeInMinutes = Double(timeForLogout)!
            var contentIsEnabled = false
            if contentEnable == "yes" {
                contentIsEnabled = true
            } else {
                contentIsEnabled = false
            }
            UserDefaults.standard.set(timeInMinutes, forKey: "timeForLogout")
            UserDefaults.standard.set(contentIsEnabled, forKey: "contentIsEnabled")
        }
    }
    
    
    func setLetterSpacing(placeholder: String) -> NSMutableAttributedString {
        let text = placeholder
        let textRange = NSMakeRange(0, text.count)
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedStringKey.kern, value: 1, range: textRange)
        return attributedString
    }
    
    func siteNameifValid(siteName: String) -> String {
        for element in sitesList {
            if element.dropFirst(7) == siteName.lowercased() || element.dropFirst(8) == siteName.lowercased() || element == siteName.lowercased() {
                return element.lowercased()
            }
        }
        return ""
    }
    
    @IBAction func LoginAction(_ sender: UIButton) {
        
        if reachability.connection == .none || sitesList.isEmpty {
            popupWarning(titleMessage: "Warning", describing: "No internet Connection")
        } else {
            
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        let siteName = websiteInput.text
        if (websiteInput.text?.isEmpty)! || (userNameInput.text?.isEmpty)! || (passwordInput.text?.isEmpty)! {
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            popupWarning(titleMessage: "Warning", describing: "All fields are required")
        } else {
            let isValid = siteNameifValid(siteName: siteName!)
            if isValid != "" {
                RealmService.deleteWebsite()
                let webSiteInstance = WebSiteModel()
                webSiteInstance.websiteUrl = isValid
                RealmService.writeIntoRealm(object: webSiteInstance)
                LoginRequest.loginRequest(login: userNameInput.text!, password: passwordInput.text!){ (completion, code) in
                    switch completion {
                    case true:
                        self.addNewSite()
                        self.addNewLogin()
                        self.pushCorrectController()
                        break
                    case false:
                        if code == 404 {
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                            self.popupWarning(titleMessage: "Server error", describing: "Please, try again later.")
                        } else {
                            self.activityIndicator.stopAnimating()
                            self.view.isUserInteractionEnabled = true
                            self.popupWarning(titleMessage: "Warning", describing: "User not found.")
                        }
                        break
                    }
                }
            } else {
                activityIndicator.stopAnimating()
                view.isUserInteractionEnabled = true
                popupWarning(titleMessage: "Warning", describing: "Website is incorrect")
            }
        }
        }
    }

    func addNewLogin() {
        if RealmService.getDefaultUserName().count > 0{
            if RealmService.getDefaultUserName()[0].isDefault {
                RealmService.deleteDefaultUserName()
                let defaultUserNameInstance = DefaultUserNameModel()
                defaultUserNameInstance.isDefault = true
                defaultUserNameInstance.savedLogin = RealmService.getLoginModel()[0].login!
                RealmService.writeIntoRealm(object: defaultUserNameInstance)
            }
        }
    }
    
    func addNewSite() {
        if RealmService.getSettingsSitesModel().count == 0 {
            let settingsSiteInstance = SettingsSitesModel()
            settingsSiteInstance.siteName = RealmService.getWebSiteModel()[0].websiteUrl!
            RealmService.writeIntoRealm(object: settingsSiteInstance)
        } else {
            let PDFInstance = realm.objects(SettingsSitesModel.self).filter("siteName = '"+RealmService.getWebSiteModel()[0].websiteUrl!+"'")
            print(PDFInstance)
            if PDFInstance.count == 0 {
                let settingsSiteInstance = SettingsSitesModel()
                settingsSiteInstance.siteName = RealmService.getWebSiteModel()[0].websiteUrl!
                RealmService.writeIntoRealm(object: settingsSiteInstance)
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
            documentInstance.userLogin = RealmService.getLoginModel()[0].login!
            RealmService.writeIntoRealm(object: documentInstance)
            
            let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let StartWorkViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kStartWorkViewController") as! StartWorkVC
            navigationController?.pushViewController(StartWorkViewController, animated: false)
        }
    }
    func preparingApplication() {
        if RealmService.getDefaultUserName().count > 0{
            if RealmService.getDefaultUserName()[0].isDefault {
                userNameInput.text = RealmService.getDefaultUserName()[0].savedLogin!
            }
        }
        if RealmService.getDisplayTime().count == 0 {
            let displayTimeInstance = DisplayTimeModel()
            displayTimeInstance.displayTime = 259200
            RealmService.writeIntoRealm(object: displayTimeInstance)
        }
        if RealmService.getDocumentData().count > 0 {
            if (RealmService.getDocumentData().last?.imageArrayData.isEmpty)! || !(RealmService.getDocumentData().last?.isGenerated)! {
                try! realm.write {
                    self.realm.delete((RealmService.getDocumentData().last?.imageArrayData)!)
                }
                RealmService.deleteLastDocument()
            }
        }
        if RealmService.getWebSiteModel().count > 0 {
            let sitesArray = RealmService.getSettingsSitesModel()
            for element in sitesArray {
                if element.isDefault {
                    let textWOHTTP = element.siteName!.components(separatedBy: "//")
                    websiteInput.text = textWOHTTP[1]
                }
            }
        }
        if LoginModel.tokenIsValid() {
            pushCorrectController()
        }
        
    }
    
    func popupWarning(titleMessage: String, describing: String) {
        let alert = UIAlertController(title: titleMessage, message: describing, preferredStyle: .alert)
        present(alert, animated: false, completion: nil)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .`default`, handler: { _ in
            self.dismiss(animated: false, completion: nil)
        }))
    }
    
    @IBAction func loginWithQRAction(_ sender: UIButton) {
        //popupWarning(titleMessage: "Sorry...", describing: "We're Working On It!")
        
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
        ScanQRViewController.loginWithQR = true
        navigationController?.pushViewController(ScanQRViewController, animated: false)
        
    }
    
}
