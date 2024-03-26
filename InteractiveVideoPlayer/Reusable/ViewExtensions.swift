//
//  ViewExtensions.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import SwiftUI

extension View {
    
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}
