//
//  Save-Debug.swift
//  Osmium
//
//  Created by Francesco on 30/05/24.
//

import UIKit

extension ViewController {
    
    @objc func handleSaveMedia(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isEnabled = userInfo["saveMedia"] as? Bool else {
            return
        }
        self.saveMedia = isEnabled
    }
    
    @objc func handleDebug(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let isEnabled = userInfo["debugPlease"] as? Bool else {
            return
        }
        self.debug = isEnabled
    }
    
}
