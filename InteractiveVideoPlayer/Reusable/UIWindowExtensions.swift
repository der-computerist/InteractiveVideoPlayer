//
//  UIWindowExtensions.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import UIKit

extension UIWindow {
    
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
