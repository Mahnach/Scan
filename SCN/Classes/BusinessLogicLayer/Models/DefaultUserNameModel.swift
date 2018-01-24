//
//  DefaultUserNameModel.swift
//  SCN
//
//  Created by BAMFAdmin on 15.01.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class DefaultUserNameModel: Object {
    @objc dynamic var isDefault = false
    @objc dynamic var savedLogin: String?
}
