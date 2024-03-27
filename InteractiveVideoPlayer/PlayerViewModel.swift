//
//  PlayerViewModel.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import AVKit
import Combine
import CoreMotion

class PlayerViewModel {
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Playback
    let player: AVPlayer
    private var isPlaying = false
    
    let maxVolume: Float = 1.0
    let minVolume: Float = 0.0
    var volume: Float = 1.0 {
        didSet {
            if volume > maxVolume { volume = maxVolume }
            if volume < minVolume { volume = minVolume }
            player.volume = volume
        }
    }
    
    // MARK: Motion Detection
    private let motionManager = CMMotionManager()
    private let motionUpdateInterval = 1.0 / 50.0
    private let queue = OperationQueue()
    private let rotationThreshold = 0.0174133  // 1 degree
    
    /** Rotation around the 'x' axis */
    private var pitch = 0.0 {
        didSet(oldPitch) {
            if pitch > oldPitch, pitch - oldPitch >= rotationThreshold {
                increaseVolume()
            } else if pitch < oldPitch, oldPitch - pitch >= rotationThreshold {
                decreaseVolume()
            }
        }
    }
    
    /** Rotation around the 'z' axis */
    private var yaw = 0.0 {  // rotation around the 'z' axis
        didSet {
            
        }
    }
    
    
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
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
    
    // MARK: Playback
    func play() {
        player.play()
    }
    
    func togglePlayback() {
        isPlaying ? player.pause() : player.play()
    }
    
    private func increaseVolume() {
        volume += 0.1
    }
    
    private func decreaseVolume() {
        volume -= 0.1
    }
    
    // MARK: Motion Detection
    func startDeviceMotionMonitoring() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = motionUpdateInterval
            motionManager.startDeviceMotionUpdates(
                using: .xArbitraryZVertical,
                to: queue
            ) { data, error in
                guard let validData = data, error == nil else {
                    return
                }
                self.pitch = validData.attitude.pitch
                self.yaw = validData.attitude.yaw
            }
        }
    }
}
