//
//  StartWorkViewController.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import UIKit

class StartWorkVC: UIViewController{

    @IBOutlet weak var clickPlusView: UIView!
    
    // MARK: - Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        clickPlusView.layer.cornerRadius = 20;
        clickPlusView.layer.masksToBounds = true;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func goToScanQRAction(_ sender: UIButton) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let ScanQRViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kScanQRViewController") as! ScanQRVC
        navigationController?.pushViewController(ScanQRViewController, animated: false)
    }
    
    @IBAction func goToSettingsAction(_ sender: UIButton) {
        let MainScreenStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let SettingsViewController = MainScreenStoryboard.instantiateViewController(withIdentifier: "kSettingsViewController") as! SettingsVC
        navigationController?.pushViewController(SettingsViewController, animated: true)
    }
    
}
