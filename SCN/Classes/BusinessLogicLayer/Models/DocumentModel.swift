//
//  DocumentModel.swift
//  SCN
//
//  Created by BAMFAdmin on 16.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation
import RealmSwift

class DocumentModel: Object{
    @objc dynamic var id = 0
    var imageArrayData = List<ImageModel>()
    @objc dynamic var qrCode: String?
    @objc dynamic var isGenerated = false
    @objc dynamic var createDate: String?
    @objc dynamic var date: Date?
    @objc dynamic var documentName: String?
    @objc dynamic var status = false

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(DocumentModel.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}


