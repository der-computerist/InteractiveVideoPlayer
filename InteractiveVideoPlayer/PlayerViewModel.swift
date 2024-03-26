//
//  PlayerViewModel.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import AVKit
import Combine

class PlayerViewModel {
    // MARK: - Properties
    let player: AVPlayer
    private var isPlaying = false
    
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: - Methods
    init(url: URL) {
        player = AVPlayer(url: url)
        
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    self?.isPlaying = true
                case .paused:
                    self?.isPlaying = false
                case .waitingToPlayAtSpecifiedRate:
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &subscriptions)
    }
    
    func play() {
        player.play()
    }
    
    func togglePlayback() {
        isPlaying ? player.pause() : player.play()
    }
}
