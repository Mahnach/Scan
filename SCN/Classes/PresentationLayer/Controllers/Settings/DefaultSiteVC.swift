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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RealmService.getSettingsSitesModel().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayTimeCell") as! DIsplayTimeTableViewCell
        switch indexPath.row {
        case 0:
            cell.displayOption.text = "3 days"
        case 1:
            cell.displayOption.text = "1 week"
        case 2:
            cell.displayOption.text = "2 weeks"
        case 3:
            cell.displayOption.text = "1 month"
        case 4:
            cell.displayOption.text = "All documents"
        default:
            break
        }
        return cell
        
    }

}
