//
//  StringConverter.swift
//  SCN
//
//  Created by BAMFAdmin on 21.04.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
