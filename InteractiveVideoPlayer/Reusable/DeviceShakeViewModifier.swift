//
//  DeviceShakeViewModifier.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import SwiftUI

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}
