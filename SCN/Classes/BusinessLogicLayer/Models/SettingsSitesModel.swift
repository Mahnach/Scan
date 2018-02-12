//
//  WebSitesModel.swift
//  SCN
//
//  Created by BAMFAdmin on 15.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class SettingsSitesModel: Object {
    @objc dynamic var siteName: String?
    @objc dynamic var isDefault = false
}
