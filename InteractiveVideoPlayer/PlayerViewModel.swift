//
//  PlayerViewModel.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import AVKit

struct PlayerViewModel {
    // MARK: - Properties
    let player: AVPlayer
    
    // MARK: - Methods
    init(url: URL) {
        player = AVPlayer(url: url)
    }
    
    func play() {
        player.play()
    }
}
