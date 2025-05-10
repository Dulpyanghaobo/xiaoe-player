//
//  VideoViewControllerProtocol.swift
//  AntPlayerH
//
//  Created by i564407 on 7/27/24.
//

import Foundation
import IJKMediaFramework

protocol VideoViewModelProtocol {
    func prepareToPlay()
    func shutdown()
    func fetchDetails()
    func fetchComments()
    func fetchPersonalNotes()
    func fetchBulletComments()
}

protocol VideoSubViewProtocol: AnyObject {
    func updateContent()
}

protocol VideoPlayerProtocol: AnyObject {
    var playbackState: IJKMPMoviePlaybackState { get }
    var loadState: IJKMPMovieLoadState { get }
}

protocol VideoPlayerViewProtocol: AnyObject {
    var delegate: VideoPlayerViewDelegate? { get set }
    func setupPlayer(with videoPlayer: VideoPlayer)
    func updatePlaybackState(_ state: IJKMPMoviePlaybackState)
    func updateLoadState(_ state: IJKMPMovieLoadState)
}

protocol VideoPlayerViewDelegate: AnyObject {
    func didToggleFullScreen()
    func didTapPlay()
    func didTapPause()
    func didSeek(to time: TimeInterval)
}
