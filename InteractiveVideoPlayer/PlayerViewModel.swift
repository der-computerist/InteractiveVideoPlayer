//
//  PlayerViewModel.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import AVKit
import Combine
import CoreMotion
import CoreLocation

class PlayerViewModel: NSObject {
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = []
    
    // MARK: Playback
    let player: AVPlayer
    private var isPlaying = false
    
    private let maxVolume: Float = 1.0
    private let minVolume: Float = 0.0
    private var volume: Float = 1.0 {
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
    
    /// The minimum amount of rotation in any given axis that will trigger
    /// a reaction from the app.
    private let rotationThreshold = 0.0174133  // 1 degree
    
    /// Rotation around the 'x' axis.
    private var pitch = 0.0 {
        didSet(oldPitch) {
            if pitch > oldPitch, pitch - oldPitch >= rotationThreshold {
                increaseVolume()
            } else if pitch < oldPitch, oldPitch - pitch >= rotationThreshold {
                decreaseVolume()
            }
        }
    }
    
    /// Rotation around the 'z' axis.
    private var yaw = 0.0 {
        didSet(oldYaw) {
            if yaw > oldYaw, yaw - oldYaw >= rotationThreshold {
                moveBackward()
            } else if yaw < oldYaw, oldYaw - yaw >= rotationThreshold {
                moveForward()
            }
        }
    }
    
    // MARK: Location Detection
    private var locationManager: CLLocationManager!
    private var lastKnownLocation: CLLocation?
    private var isFirstLocationUpdate = true
    
    /// The minimum distance the device's location has to change before
    /// video playback is restarted.
    private let distanceThreshold = 10.0
    
    // MARK: - Methods
    init(url: URL) {
        player = AVPlayer(url: url)
        
        super.init()
        
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
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: Playback
    func play() {
        player.play()
        startDeviceMotionMonitoring()
        startDeviceLocationMonitoring()
    }
    
    func pause() {
        player.pause()
    }
    
    func togglePlayback() {
        isPlaying ? player.pause() : player.play()
    }
    
    func restart() {
        player.pause()
        player.seek(to: .zero)
        player.play()
    }
    
    private func increaseVolume() {
        volume += 0.1
    }
    
    private func decreaseVolume() {
        volume -= 0.1
    }
    
    /// Seek forward by 5 seconds
    private func moveForward() {
        let currentTime = player.currentTime()
        let fiveSeconds = CMTime(seconds: 5, preferredTimescale: currentTime.timescale)
        let newTime = currentTime + fiveSeconds
        player.seek(to: newTime)
    }
    
    /// Seek backward by 5 seconds
    private func moveBackward() {
        let currentTime = player.currentTime()
        let fiveSeconds = CMTime(seconds: 5, preferredTimescale: currentTime.timescale)
        let newTime = currentTime - fiveSeconds
        player.seek(to: newTime)
    }
    
    // MARK: Motion Detection
    private func startDeviceMotionMonitoring() {
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
    
    // MARK: Location Detection
    private func startDeviceLocationMonitoring() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Receive location updates every 10 meters of movement.
        // It's a useful parameter, yet not 100% reliable, which is why we
        // manually check the distance every time we receive a new location.
        locationManager.distanceFilter = distanceThreshold
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}

// MARK: - CLLocationManagerDelegate
extension PlayerViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ _: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if isFirstLocationUpdate {
            guard let firstLocation = locations.last else { return }
            lastKnownLocation = firstLocation
            isFirstLocationUpdate = false
            return
        }
        
        guard let newLocation = locations.last, let lastLocation = self.lastKnownLocation else {
            return
        }
        
        if newLocation.distance(from: lastLocation) >= distanceThreshold {
            restart()
        }
        
        self.lastKnownLocation = newLocation
    }
    
    func locationManager(_ _: CLLocationManager, didFailWithError error: Error) {
        // In a real-world app, we should gracefully handle the error.
        // For now, just print a message to the console.
        print("***ERROR***: Unable to retrieve a location value")
        print(error.localizedDescription)
    }
}
