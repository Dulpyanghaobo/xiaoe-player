//
//  VideoPlayer.swift
//  AntPlayerH
//
//  Created by i564407 on 7/27/24.
//

import Foundation
import IJKMediaFramework

protocol VideoPlayerDelegate: AnyObject {
    func playerLoadStateDidChange(_ player: VideoPlayer)
    func playerPlaybackStateDidChange(_ player: VideoPlayer)
    func playerPlaybackDidFinish(_ player: VideoPlayer, reason: IJKMPMovieFinishReason)
    func playerPlaybackParpareDidFinish(_ player: VideoPlayer)
}

class VideoPlayer: VideoPlayerProtocol {

    var playbackState: IJKMPMoviePlaybackState {
        return player?.playbackState ?? IJKMPMoviePlaybackState.playing
    }

    var loadState: IJKMPMovieLoadState {
        return player?.loadState ?? IJKMPMovieLoadState.playable
    }
    
    var watermark: Any?  // 可以是文字或图片的水印
    
    // Watermark image property
    private var watermarkLayer: CALayer?
                     
    var player: IJKMediaPlayback?
    weak var delegate: VideoPlayerDelegate?


    init(url: URL, watermark: Any? = nil) {
//        self.watermark = watermark
        prepareVideo(url: url)
    }
    
    func prepareVideo(url: URL) {
        self.setupPlayer(with: url)

        self.player?.play()
//
//        DispatchQueue.global(qos: .background).async {
//
//            // 准备完成后在主线程中播放
//            DispatchQueue.main.async {
//            }
//        }
    }

    func setupPlayer(with url: URL) {
        let options = IJKFFOptions.byDefault()
        options?.setFormatOptionValue("mov,mp4,m4a,3gp,3g2,mj2", forKey: "iformat")
        options?.setPlayerOptionIntValue(20 * 1024 * 1024, forKey: "probesize")
        options?.setPlayerOptionIntValue(5 * 1000000, forKey: "analyzeduration")
        
        player = IJKFFMoviePlayerController(contentURL: url, with: options)
        player?.prepareToPlay()
        setupObservers()
        addWatermark()  // Add watermark if available
    }
    
    private func addWatermark() {
//        guard let watermark = watermark else { return }
//        
//        let watermarkType = checkWatermarkType(watermark)
//        
//        if watermarkType == "text" {
//            let label = UILabel()
//            label.text = watermark as? String
//            label.textColor = .white
//            label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
//            label.layer.cornerRadius = 5
//            label.clipsToBounds = true
//            self.player?.view.addSubview(label)
//            label.snp.makeConstraints { make in
//                make.leading.top.equalToSuperview().offset(10)
//            }
//        } else if watermarkType == "image" {
//            let imgView = UIImageView()
//            if let imagePath = (watermark as? [String: Any])?["image"] as? String, let image = UIImage(named: imagePath) {
//                imgView.image = image
//                self.player?.view.addSubview(imgView)
//                imgView.snp.makeConstraints { make in
//                    make.leading.top.equalToSuperview().offset(10)
//                    make.width.height.equalTo(50)  // 设置水印图片的大小
//                }
//            }
//        }
    }

    // 检查水印类型
    private func checkWatermarkType(_ watermark: Any) -> String {
        if let text = watermark as? String {
            return "text"
        } else if let imageDict = watermark as? [String: Any], imageDict["image"] != nil {
            return "image"
        }
        return "none"
    }
    func play() {
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    func stop() {
        player?.shutdown()
        self.player?.view.removeFromSuperview()
        self.player?.stop()
        self.removeObservers()
        player = nil
    }

    func seek(to time: TimeInterval) {
        player?.currentPlaybackTime = time
    }

    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadStateDidChange(_:)), name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackDidFinish(_:)), name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(mediaIsPreparedToPlayDidChange(_:)), name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.addObserver(self, selector: #selector(moviePlayBackStateDidChange(_:)), name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
        
    }

    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerLoadStateDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackDidFinish, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange, object: player)
        NotificationCenter.default.removeObserver(self, name: .IJKMPMoviePlayerPlaybackStateDidChange, object: player)
    }

    @objc private func loadStateDidChange(_ notification: Notification) {
        delegate?.playerLoadStateDidChange(self)
    }

    @objc private func moviePlayBackDidFinish(_ notification: Notification) {
        let reason = (notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? NSNumber)?.intValue ?? IJKMPMovieFinishReason.playbackEnded.rawValue
        delegate?.playerPlaybackDidFinish(self, reason: IJKMPMovieFinishReason(rawValue: reason)!)
    }

    @objc private func mediaIsPreparedToPlayDidChange(_ notification: Notification) {
        self.delegate?.playerPlaybackParpareDidFinish(self)
    }

    @objc private func moviePlayBackStateDidChange(_ notification: Notification) {
        delegate?.playerPlaybackStateDidChange(self)
        //自动播放下一个视频
    }
}
