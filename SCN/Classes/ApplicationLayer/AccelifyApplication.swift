//
//  AccelifyApplication.swift
//  SCN
//
//  Created by BAMFAdmin on 27.02.18.
//  Copyright © 2018 BAMFAdmin. All rights reserved.
//

import Foundation
import UIKit


class AccelifyApplication: UIApplication {
    
    // MARK: - Properties
    
    private let timeoutInSeconds = UserDefaults.standard.double(forKey: "timeForLogout") * 60.0;

    var idleTimer: Timer?
    
    
    // MARK: - Methods
    
    override init() {
        super.init()

        resetIdleTimer()
    }
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if idleTimer != nil {
            resetIdleTimer()
        }
        
        if let allTouches = event.allTouches {
            for touch in allTouches {
                if touch.phase == .began {
                    resetIdleTimer()
                }
            }
        }
    }
    
    func appWillResignActive() {
        idleTimerExceeded()
    }
    
    func resetIdleTimer() {
        if let idleTimer = idleTimer {
            idleTimer.invalidate()
        }
        
        idleTimer = Timer.scheduledTimer(timeInterval: timeoutInSeconds,
                                         target: self,
                                         selector: #selector(idleTimerExceeded),
                                         userInfo: nil,
                                         repeats: false)
    }
    
    @objc func idleTimerExceeded() {
        NotificationCenter.default.post(name: Notification.Name.ApplicationTimeout, object: self)
    }
}

// MARK: - Notification.Name
extension Notification.Name {
    static let ApplicationTimeout = Notification.Name("ApplicationTimeout")
}

