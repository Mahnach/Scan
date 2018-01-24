//
//  DefaultSiteViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 15.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit

class DefaultSiteVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var siteLabel: UILabel!
    
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
        return RealmService.getSettingsSitesModel().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell") as! SiteNameTableViewCell
        cell.siteName.text = RealmService.getSettingsSitesModel()[indexPath.row].siteName!
        
        if cell.siteName.text == RealmService.getWebSiteModel()[0].websiteUrl! {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPathValue = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPathValue) as! SiteNameTableViewCell
        RealmService.deleteWebsite()
        let webSiteInstance = WebSiteModel()
        webSiteInstance.websiteUrl = currentCell.siteName.text

        RealmService.writeIntoRealm(object: webSiteInstance)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goToSettingsAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
}
