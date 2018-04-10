//
//  main.swift
//  SCN
//
//  Created by BAMFAdmin on 27.02.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import UIKit

UIApplicationMain(CommandLine.argc,
                  UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(
                    to: UnsafeMutablePointer<Int8>.self,
                    capacity: Int(CommandLine.argc)),
                  NSStringFromClass(AccelifyApplication.self),
                  NSStringFromClass(AppDelegate.self))
