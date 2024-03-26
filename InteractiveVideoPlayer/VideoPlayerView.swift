//
//  VideoPlayerView.swift
//  InteractiveVideoPlayer
//
//  Created by Enrique Aliaga on 26/03/24.
//

import AVKit
import SwiftUI

struct VideoPlayerView: View {
    
    var model: PlayerViewModel = {
        let videoURL = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4")!
        return PlayerViewModel(url: videoURL)
    }()
    
    var body: some View {
        VStack {
            VideoPlayer(player: model.player)
                .onAppear { model.play() }
                .onShake { model.togglePlayback() }
        }
        .ignoresSafeArea()
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView()
    }
}
