//
//  SettingsViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 12.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var pushFromHistory = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsTableViewCell
        switch indexPath.row {
        case 0:
            cell.settingName.text = "Display PDF History"
        case 1:
            cell.settingName.text = "Default website"
        case 2:
            cell.settingName.text = "Save username"
        case 3:
            cell.settingName.text = "Logout"
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            displayTime()
        case 1:
            break
        case 2:
            break
        case 3:
            logout()
        default:
            break
        }
    }
    
    func logout() {
        RealmService.deleteLoginData()
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let LoginViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kLoginViewController") as! LoginVC
        self.navigationController?.pushViewController(LoginViewController, animated: true)
    }
    
    func displayTime() {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let DisplayTimeViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kDisplayTimeViewController") as! DisplayTimeViewController
        self.navigationController?.pushViewController(DisplayTimeViewController, animated: true)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: false)
    }

}
