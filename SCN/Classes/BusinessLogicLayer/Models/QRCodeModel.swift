//
//  QRCodeModel.swift
//  SCN
//
//  Created by BAMFAdmin on 14.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class QRCodeModel: Object{
    @objc dynamic var qrCode: String?
    @objc dynamic var eventName: String?
    @objc dynamic var formName: String?
    @objc dynamic var studentName: String?
    @objc dynamic var studentId: String?
    @objc dynamic var isValid = false
    @objc dynamic var eventId: String?
}
