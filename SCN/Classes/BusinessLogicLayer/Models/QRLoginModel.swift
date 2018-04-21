//
//  QRLoginModel.swift
//  SCN
//
//  Created by BAMFAdmin on 20.04.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class QRLoginModel: Object{
    @objc dynamic var qrCode: String?
    @objc dynamic var customer: String?
    @objc dynamic var site: String?
    @objc dynamic var login: String?
    @objc dynamic var password: String?
    @objc dynamic var isValid = false

}
