//
//  FileManager+CleanDirectory.swift
//  SCN
//
//  Created by BAMFAdmin on 21.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation

extension FileManager {
    func clearTmpDirectory(documentName: String) {
        do {
            let fileName = NSTemporaryDirectory()+documentName
            try self.removeItem(atPath: fileName)
        } catch {
            print(error)
        }
    }
}

