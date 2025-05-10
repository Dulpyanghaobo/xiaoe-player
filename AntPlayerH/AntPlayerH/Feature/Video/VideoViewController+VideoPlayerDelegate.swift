//
//  VideoViewController+VideoPlayerDelegate.swift
//  AntPlayerH
//
//  Created by i564407 on 8/15/24.
//

import Foundation
import IJKMediaFramework

extension VideoPlayerViewController: VideoPlayerDelegate {
    func playerLoadStateDidChange(_ player: VideoPlayer) {
        updateLoadState(player.loadState)
    }
    func playerPlaybackStateDidChange(_ player: VideoPlayer) {
        updatePlaybackState(player.playbackState)
    }
    func playerPlaybackDidFinish(_ player: VideoPlayer, reason: IJKMPMovieFinishReason) {
    }
    
    func playerPlaybackParpareDidFinish(_ player: VideoPlayer) {
        self.player?.player?.currentPlaybackTime =  TimeInterval(self.viewModel?.courseInfo?.videoLastPlayTime ?? 0)
    }
    
}
