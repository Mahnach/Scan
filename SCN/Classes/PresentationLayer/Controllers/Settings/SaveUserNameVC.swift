//
//  SaveUserNameVC.swift
//  SCN
//
//  Created by BAMFAdmin on 15.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit

class SaveUserNameVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var savedOption: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if RealmService.getDefaultUserName().count > 0 {
            switch RealmService.getDefaultUserName()[0].isDefault {
            case true:
                savedOption = "YES"
            case false:
                savedOption = "NO"
            }
        } else {
            savedOption = "NO"
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "saveUserNameCell") as! SaveUserNameTableViewCell
        switch indexPath.row {
        case 0:
            cell.saveOption.text = "YES"
        case 1:
            cell.saveOption.text = "NO"
        default:
            break
        }
        if cell.saveOption.text == savedOption {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if LoginModel.tokenIsValid() {
            RealmService.deleteDefaultUserName()
            let defaultUserNameInstance = DefaultUserNameModel()
            if indexPath.row == 0 {
                defaultUserNameInstance.isDefault = true
                defaultUserNameInstance.savedLogin = RealmService.getLoginModel()[0].login!
            } else {
                defaultUserNameInstance.isDefault = false
            }
            RealmService.writeIntoRealm(object: defaultUserNameInstance)
            
            _ = navigationController?.popViewController(animated: true)
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

    @IBAction func goToSettingsAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
}
