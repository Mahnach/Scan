//
//  DisplayTimeViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 15.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import UIKit

class DisplayTimeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var choosenTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        switch RealmService.getDisplayTime()[0].displayTime {
        case 259200:
            choosenTime = "3 days"
        case 604800:
            choosenTime = "1 week"
        case 1209600:
            choosenTime = "2 weeks"
        case 2419200:
            choosenTime = "1 month"
        case -1:
            choosenTime = "All documents"
        default:
            choosenTime = "3 days"
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
        if cell.displayOption.text == choosenTime {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RealmService.deleteDisplayTime()
        let displayTimeInstance = DisplayTimeModel()
        
        switch indexPath.row {
        case 0:
            displayTimeInstance.displayTime = 259200
        case 1:
            displayTimeInstance.displayTime = 604800
        case 2:
            displayTimeInstance.displayTime = 1209600
        case 3:
            displayTimeInstance.displayTime = 2419200
        case 4:
            displayTimeInstance.displayTime = -1
        default:
            displayTimeInstance.displayTime = 0
        }
        RealmService.writeIntoRealm(object: displayTimeInstance)
        _ = navigationController?.popViewController(animated: true)
        
    }

    @IBAction func backToSettingsAction(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
}
