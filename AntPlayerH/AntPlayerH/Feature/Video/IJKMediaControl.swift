//
//  IJKMediaControl.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//
import UIKit
import IJKMediaFramework
import SnapKit
import Photos

enum MediaControlAction {
    case titleButton
    case speed
    case aspectRatio
    case selectTrack
    case captureFrame
    case toggleDanmaku
    case aiCaption
}

protocol IJKMediaControlDelegate: AnyObject {
    func didTapButton(action: MediaControlAction)
    func currentPlaybackTimeDidChange(_ currentTime: TimeInterval)
    func getCaptionImage(image: UIImage)
}

class IJKMediaControl: UIControl {
    
    weak var delegate: IJKMediaControlDelegate?

    var isFullScreen: Bool = false // 用于判断当前是否为全屏模式

    weak var delegatePlayer: IJKMediaPlayback?
    
    var overlayPanel: UIView!
    var fullScreenOverlayPanel: UIView!  // 新增全屏控制面板
    
    var playButton =  UIButton.init(type: .custom)
    var currentTimeLabel = UILabel()
    var totalDurationLabel = UILabel()
    var mediaProgressSlider = UISlider(frame: .zero)
    var fullScreenButton = UIButton(type: .custom)  // 添加全屏按钮
    let fullMediaProgressSlider: CustomSlider = {
        let fullMediaProgressSlider = CustomSlider(frame: .zero)
        let thumbImage = UIImage(systemName: "circle.fill")?.withTintColor(AppColors.themeColor, renderingMode: .alwaysOriginal).resized(to: CGSize(width: 30, height: 30))
        fullMediaProgressSlider.setThumbImage(thumbImage, for: .normal)
        return fullMediaProgressSlider
    }()
    
    // 新增全屏控制面板的按钮
    var fullPlayButton =  UIButton.init(type: .custom)
    var fullCurrentTimeLabel = UILabel()
    var fullTotalDurationLabel = UILabel()
    var speedButton = UIButton(type: .custom)
    var selectTrackButton = UIButton(type: .custom)
    var captureFrameButton = UIButton(type: .custom)
    var aspectRatioButton = UIButton(type: .custom)
    var aiCaptionButton = UIButton(type: .custom)
    var titleButton = UIButton(type: .custom)

    var danmakuToggleButton = UIButton(type: .custom)
    var exitFullScreenButton = UIButton(type: .custom)
    
    private var isMediaSliderBeingDragged = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupFullScreenUI()  // 设置全屏控制面板
        updateViewForFullScreen(isFullScreen)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupFullScreenUI()  // 设置全屏控制面板
        updateViewForFullScreen(isFullScreen)
    }
    
    private func setupUI() {
        overlayPanel = UIView()
        overlayPanel.backgroundColor = .black.withAlphaComponent(0.05)
        addSubview(overlayPanel)

        playButton.setImage(UIImage.init(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        overlayPanel.addSubview(playButton)
                
        currentTimeLabel = UILabel()
        currentTimeLabel.textColor = .white
        overlayPanel.addSubview(currentTimeLabel)
        currentTimeLabel.text = "00:00"
        totalDurationLabel = UILabel()
        totalDurationLabel.textColor = .white
        totalDurationLabel.text = "00:00"
        overlayPanel.addSubview(totalDurationLabel)
        overlayPanel.addSubview(fullScreenButton)

        fullScreenButton.setImage(UIImage.init(named: "biggest")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)

        fullScreenButton.addTarget(self, action: #selector(fullScreenButtonTapped), for: .touchUpInside)
        mediaProgressSlider.setThumbImage(UIImage(named: "slider_icon"), for: .normal)
        mediaProgressSlider.minimumTrackTintColor = AppColors.themeColor  // 设置进度条颜色
        mediaProgressSlider.maximumTrackTintColor = .white
//        mediaProgressSlider.thumbTintColor = AppColors.themeColor  // 设置滑块颜色
        mediaProgressSlider.addTarget(self, action: #selector(beginDragMediaSlider), for: .touchDown)
        mediaProgressSlider.addTarget(self, action: #selector(endDragMediaSlider), for: .touchUpInside)
        mediaProgressSlider.addTarget(self, action: #selector(endDragMediaSlider), for: .touchUpOutside)
        mediaProgressSlider.addTarget(self, action: #selector(continueDragMediaSlider), for: .valueChanged)
        overlayPanel.addSubview(mediaProgressSlider)
        overlayPanel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        playButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        fullScreenButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        totalDurationLabel.snp.makeConstraints { make in
            make.right.equalTo(fullScreenButton.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }
        currentTimeLabel.snp.makeConstraints { make in
            make.right.equalTo(totalDurationLabel.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }
        mediaProgressSlider.snp.makeConstraints { make in
            make.left.equalTo(playButton.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.right.equalTo(currentTimeLabel.snp.left).offset(-8)
        }
    }
    
    private func setupFullScreenUI() {
        fullScreenOverlayPanel = UIView()
        fullScreenOverlayPanel.backgroundColor = .black.withAlphaComponent(0.7)
        addSubview(fullScreenOverlayPanel)
        fullPlayButton.setImage(UIImage.init(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        addSubview(fullPlayButton)
        fullPlayButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

        // 倍速播放按钮
        speedButton.setTitle("倍数", for: .normal)
        titleButton.setTitle("标题", for: .normal)
        titleButton.setTitleColor(.white, for: .normal)

        titleButton.addTarget(self, action: #selector(titleButtonTapped), for: .touchUpInside)

        
        speedButton.setTitleColor(.white, for: .normal)
        speedButton.addTarget(self, action: #selector(speedButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(speedButton)
        fullScreenOverlayPanel.addSubview(fullCurrentTimeLabel)
        fullScreenOverlayPanel.addSubview(fullTotalDurationLabel)
        fullScreenOverlayPanel.addSubview(aspectRatioButton)

        
        fullCurrentTimeLabel.textColor = .white
        overlayPanel.addSubview(currentTimeLabel)
        fullTotalDurationLabel.textColor = .white
        // 选择视频轨道按钮
        selectTrackButton.setImage(UIImage.init(systemName: "forward.end")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        selectTrackButton.addTarget(self, action: #selector(nextTrackButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(selectTrackButton)
        aspectRatioButton.setTitle("尺寸", for: .normal)
        aspectRatioButton.setTitleColor(.white, for: .normal)
        aspectRatioButton.addTarget(self, action: #selector(aspectRatioButtonTapped), for: .touchUpInside)

        // 截取视频帧按钮
        captureFrameButton.setImage(UIImage.init(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        captureFrameButton.addTarget(self, action: #selector(captureFrameButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(captureFrameButton)

        // 弹幕控制按钮
        danmakuToggleButton.setImage(UIImage(named: "danmuguanbi_icon"), for: .normal)
        danmakuToggleButton.addTarget(self, action: #selector(danmakuToggleButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(danmakuToggleButton)
        // 弹幕控制按钮
        aiCaptionButton.setTitle("字幕", for: .normal)
        aiCaptionButton.setTitleColor(.white, for: .normal)
        aiCaptionButton.addTarget(self, action: #selector(aiCaptionButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(aiCaptionButton)
        
        // 退出全屏按钮
        exitFullScreenButton.setImage(UIImage(named: "mulu_icon")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        exitFullScreenButton.addTarget(self, action: #selector(selectTrackButtonTapped), for: .touchUpInside)
        fullScreenOverlayPanel.addSubview(exitFullScreenButton)
        fullMediaProgressSlider.setThumbImage(UIImage(named: "slider_icon"), for: .normal)
        fullMediaProgressSlider.minimumTrackTintColor = AppColors.themeColor  // 设置进度条颜色
        fullMediaProgressSlider.maximumTrackTintColor = .white
//        mediaProgressSlider.thumbTintColor = AppColors.themeColor  // 设置滑块颜色
        fullMediaProgressSlider.addTarget(self, action: #selector(beginDragMediaSlider), for: .touchDown)
        fullMediaProgressSlider.addTarget(self, action: #selector(endDragMediaSlider), for: .touchUpInside)
        fullMediaProgressSlider.addTarget(self, action: #selector(endDragMediaSlider), for: .touchUpOutside)
        fullMediaProgressSlider.addTarget(self, action: #selector(continueDragMediaSlider), for: .valueChanged)
        fullScreenOverlayPanel.addSubview(fullMediaProgressSlider)

        // 设置全屏控制面板约束
        setupFullScreenOverlayConstraints()
    }
    
    func updateViewForFullScreen(_ isFullScreen: Bool) {
        overlayPanel.isHidden = isFullScreen
        fullScreenOverlayPanel.isHidden = !isFullScreen
        refreshMediaControl()
    }

    @objc private func speedButtonTapped() {
        delegate?.didTapButton(action: .speed)
    }
    
    @objc private func titleButtonTapped() {
        
        delegate?.didTapButton(action: .titleButton)
    }
    
    @objc private func nextTrackButtonTapped(_ sender: UIButton) {
        
    }
    

    @objc private func aspectRatioButtonTapped(_ sender: UIButton) {
        delegate?.didTapButton(action: .aspectRatio)
    }

    @objc private func selectTrackButtonTapped() {
        delegate?.didTapButton(action: .selectTrack)
    }

    @objc func captureFrameButtonTapped() {
        captureFrameForIJKPlayer()
    }
    
    func captureFrameForIJKPlayer() -> UIImage {
        if let image = self.delegatePlayer?.thumbnailImageAtCurrentTime() {
            self.delegate?.getCaptionImage(image: image)
            return image
        }
        return UIImage()
    }

    // Function to save UIImage to the photo album
    func saveImageToAlbum(image: UIImage) {
        // Request authorization to access the photo library
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                // Perform changes to save the image
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                    DispatchQueue.main.async {
                        self.delegate?.didTapButton(action: .captureFrame)
                    }
                }, completionHandler: { success, error in
                    if success {
                        print("Image saved successfully!")
                    } else if let error = error {
                        print("Error saving image: \(error.localizedDescription)")
                    }
                })
            } else {
                print("Authorization denied.")
            }
        }
    }

    
    @objc private func danmakuToggleButtonTapped(_ sender: UIButton) {
        sender.isSelected.toggle() // 切换选中状态
        if sender.isSelected {
            // 选中状态，显示选中的图片
            sender.setImage(UIImage.init(named: "danmuguanbi_icon"), for: .selected)
        } else {
            // 非选中状态，显示未选中的图片
            sender.setImage(UIImage(named: "danmudakai_icon"), for: .normal)
        }
        delegate?.didTapButton(action: .toggleDanmaku)
    }
    
    @objc private func aiCaptionButtonTapped() {
        delegate?.didTapButton(action: .aiCaption)
    }
    
    private func setupFullScreenOverlayConstraints() {
        fullScreenOverlayPanel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        fullPlayButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(4)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }

        selectTrackButton.snp.makeConstraints { make in
            make.left.equalTo(fullPlayButton.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        
        fullCurrentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(selectTrackButton.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        fullTotalDurationLabel.snp.makeConstraints { make in
            make.left.equalTo(fullCurrentTimeLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }
        
        danmakuToggleButton.snp.makeConstraints { make in
            make.left.equalTo(fullTotalDurationLabel.snp.right).offset(16)
            make.centerY.equalToSuperview()
        }
        
        exitFullScreenButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        captureFrameButton.snp.makeConstraints { make in
            make.right.equalTo(exitFullScreenButton.snp.left).offset(-16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        speedButton.snp.makeConstraints { make in
            make.right.equalTo(captureFrameButton.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        aspectRatioButton.snp.makeConstraints { make in
            make.right.equalTo(speedButton.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        
        aiCaptionButton.snp.makeConstraints { make in
            make.right.equalTo(aspectRatioButton.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        fullMediaProgressSlider.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
    }
    
    @objc private func playButtonTapped() {
        guard let isPlaying = delegatePlayer?.isPlaying() else { return }
        if (!isPlaying) {
            playButton.setImage(UIImage.init(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            fullPlayButton.setImage(UIImage.init(systemName: "pause.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            self.delegatePlayer?.play()
        } else {
            playButton.setImage(UIImage.init(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
            fullPlayButton.setImage(UIImage.init(systemName: "play.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)

            self.delegatePlayer?.pause()
        }
    }

    func showNoFade() {
        overlayPanel.isHidden = false
//        fullScreenOverlayPanel.isHidden = true
        cancelDelayedHide()
        refreshMediaControl()
    }
    
    @objc func hide() {
        overlayPanel.isHidden = true
        cancelDelayedHide()
    }
    
    @objc func fullScreenButtonTapped() {
        self.isFullScreen.toggle()
        updateViewForFullScreen(isFullScreen)
        NotificationCenter.default.post(name: .toggleFullScreen, object: nil)
    }
    
    private func cancelDelayedHide() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hide), object: nil)
    }
    
    @objc private func beginDragMediaSlider() {
        isMediaSliderBeingDragged = true
    }
    
    @objc private func endDragMediaSlider() {
        isMediaSliderBeingDragged = false
        self.delegatePlayer?.currentPlaybackTime = TimeInterval(self.mediaProgressSlider.value)
        self.delegatePlayer?.currentPlaybackTime = TimeInterval(self.fullMediaProgressSlider.value)

    }
    
    @objc private func continueDragMediaSlider() {
        refreshMediaControl()
    }
    
    @objc func refreshMediaControl() {
        guard let delegatePlayer = delegatePlayer, delegatePlayer.isPlaying() else {
            return
        }
        // Duration
        let duration = delegatePlayer.duration
        let intDuration = Int(duration + 0.5)
        if intDuration > 0 {
            mediaProgressSlider.maximumValue = Float(duration)
            totalDurationLabel.text = String(format: "%02d:%02d", intDuration / 60, intDuration % 60)
            fullTotalDurationLabel.text = String(format: "%02d:%02d", intDuration / 60, intDuration % 60)
            fullMediaProgressSlider.maximumValue = Float(duration)

        } else {
            totalDurationLabel.text = "--:--"
            fullTotalDurationLabel.text = "--:--"
            mediaProgressSlider.maximumValue = 1.0
            fullMediaProgressSlider.maximumValue = 1.0
        }
        
        // Position
        var position: TimeInterval
        if isMediaSliderBeingDragged {
            position = TimeInterval(mediaProgressSlider.value)
            position = TimeInterval(fullMediaProgressSlider.value)
        } else {
            position = delegatePlayer.currentPlaybackTime
        }
        let intPosition = Int(position + 0.5)
        if intDuration > 0 {
            mediaProgressSlider.value = Float(position)
            fullMediaProgressSlider.value = Float(position)
        } else {
            mediaProgressSlider.value = 0.0
            fullMediaProgressSlider.value = 0.0
        }
        currentTimeLabel.text = String(format: "%02d:%02d", intPosition / 60, intPosition % 60)
        fullCurrentTimeLabel.text = String(format: "%02d:%02d", intPosition / 60, intPosition % 60)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(refreshMediaControl), object: nil)
        if !overlayPanel.isHidden || !fullScreenOverlayPanel.isHidden {
            perform(#selector(refreshMediaControl), with: nil, afterDelay: 0.5)
            self.delegate?.currentPlaybackTimeDidChange(self.delegatePlayer?.currentPlaybackTime ?? 0)
        }
    }
}

extension IJKMediaControl: VideoControlsViewDelegate {
    func didSelectSpeed(speedModel: SpeedModel) {
        self.delegatePlayer?.playbackRate = Float(speedModel.speed)
    }
    
    func didSelectAspectRatio(aspectRatio: IJKMPMovieScalingMode) {
        self.delegatePlayer?.scalingMode = aspectRatio
    }
    
    func didSelectTrack(track: String) {
        
    }
    
    func didSelectSubtitle(subtitle: String) {
        
    }
    
    func didSelectDanmaku(danmaku: String) {
        
    }
    
    func didSelectAiCaption(isOpen: Bool) {
        
    }
}
