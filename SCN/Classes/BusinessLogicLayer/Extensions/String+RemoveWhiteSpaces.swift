//
//  String+RemoveWhiteSpaces.swift
//  SCN
//
//  Created by BAMFAdmin on 27.12.17.
//  Copyright © 2017 BAMFAdmin. All rights reserved.
//

import Foundation


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
