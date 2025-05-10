//
//  PlayerViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/23/24.
//
import UIKit
import IJKMediaFramework
import SnapKit
import JXSegmentedView
import SnapKit
import ScreenshotPreventing

class VideoPlayerViewController: BaseViewController, VideoPlayerViewProtocol {
    
    var delegate: VideoPlayerViewDelegate?
    var onKeyboardVisibilityChanged: ((Bool, CGFloat) -> Void)?

    var isFullScreen = false
    override var shouldAutorotate: Bool {
        return isFullScreen // 仅在全屏模式下允许旋转
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isFullScreen ? .landscape : .portrait
    }
    
    var player: VideoPlayer?
    var backButton:  UIButton = {
        let button = UIButton.init(type: .custom)
        button.setImage(UIImage.init(named: "fanhui_icon_1"), for: .normal)
        return button
    }()
    
    var videoControlsView: VideoControlsView?
    var mediaControl: IJKMediaControl!
    var subtitleView: SubtitleView = SubtitleView.init()
    var videoTitlesView: VideoTitlesView = VideoTitlesView.init()
    var adverView: AdverView = AdverView.init()
    var questionOptionView: QuestionOptionView = QuestionOptionView.init(frame: .zero)
    var aiWaterView: AIWaterView = AIWaterView.init()

    
    var segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    var segmentedDtaSource: PlayerSegmentedTitleDataSource!
    
    var viewModel: VideoViewModel?
    var barrageController = BarrageController()
    
    var titleLabel: UILabel = UILabel.init()
    
    var courseDetailView: CourseDetailView!
    var commentsView: PlayerCommentsView!
    var personalNotesView: PersonalNotesView!
    var aiNotesView: PlayerAINotesView!
    var bulletCommentsView: PlayerBulletCommentsView!
    
    init(player: VideoPlayer, courseInfo: CourseInfo, onlineCoursesResponse: OnlineCoursesResponse) {
        super.init()
        setupPlayer(with: player)
        self.viewModel = VideoViewModel(onlineCoursesResponse: onlineCoursesResponse, courseInfo: courseInfo)
        viewModel?.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    private func closePlayer() {
        // 停止播放器
        player?.stop()
        // 释放播放器资源（如果有必要）
        player = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        autoPlayVideo()
    }

    // MARK: - Setup Methods
    private func setupUI() {
        setupMediaControl()
        setupSegmentedView()
        setupSubViews()
        setupSubviews() // Setup all subviews
        setupConstraints()
        self.titleLabel.text = self.viewModel?.courseInfo?.courseName
        self.titleLabel.backgroundColor = .black.withAlphaComponent(0.1)
        reloadData()
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        // Add all subviews here
        guard let playerView = self.player?.player?.view else { return }
        
        view.addSubview(playerView)
        view.addSubview(backButton)
        view.addSubview(titleLabel)
        view.addSubview(segmentedView)
        view.addSubview(videoTitlesView)
        view.addSubview(subtitleView)
        view.insertSubview(mediaControl, aboveSubview: videoTitlesView)
        view.addSubview(adverView)
        view.addSubview(aiNotesView)
        view.addSubview(questionOptionView)
        view.addSubview(listContainerView)
        view.insertSubview(aiWaterView, aboveSubview: playerView)

        self.adverView.isHidden = true
        self.player?.player?.view.addSubview(barrageController.view)
        // Setup back button action
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Additional setup for other views if needed
        titleLabel.textColor = .white
        titleLabel.backgroundColor = .black.withAlphaComponent(0.1)
    }
    
    private func setupConstraints() {
        guard let playerView = self.player?.player?.view else { return }
        mediaControl.delegatePlayer = self.player?.player
        mediaControl.delegate = self
        mediaControl.showNoFade()
        if self.isFullScreen {
            playerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else {
            playerView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(44)
                make.left.right.equalToSuperview()
                make.height.equalTo(720/1080 * UIScreen.main.bounds.width)
            }
        }
        backButton.snp.makeConstraints { make in
            make.top.equalTo(playerView).offset(8)
            make.left.equalToSuperview().offset(8)
            make.height.width.equalTo(32)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(8)
            make.centerY.equalTo(backButton)
            make.width.equalTo(270)
        }
        
        segmentedView.snp.makeConstraints { make in
            make.top.equalTo(playerView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth)
            make.height.equalTo(44)
        }
        
        mediaControl.snp.makeConstraints { make in
            make.bottom.equalTo(playerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        videoTitlesView.snp.makeConstraints { make in
            make.bottom.equalTo(playerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.isFullScreen ?  56: 23)
        }
        aiWaterView.snp.makeConstraints { make in
            make.center.equalTo(playerView)
            make.width.equalTo(screenWidth)
            make.height.equalTo(300)
        }
        
        subtitleView.snp.makeConstraints { make in
            make.centerX.equalTo(mediaControl)
            make.bottom.equalTo(mediaControl.snp.top)
            make.left.right.equalToSuperview().inset(44)
            make.height.equalTo(32)
        }
        
        adverView.snp.makeConstraints { make in
            make.center.equalTo(playerView)
            make.width.equalTo(320)
            make.height.equalTo(200)
        }
        
        questionOptionView.snp.makeConstraints { make in
            make.centerX.equalTo(playerView)
            make.centerY.equalTo(playerView).offset(8)
            make.width.equalTo(320)
            make.height.equalTo(200)
        }
        
        listContainerView.snp.makeConstraints { make in
            make.top.equalTo(segmentedView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        barrageController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        barrageController.didMove(toParent: self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(toggleFullScreen), name: .toggleFullScreen, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if isFullScreen {
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let keyboardHeight = keyboardFrame.height
                let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
                
                DispatchQueue.main.async {
                    // 调整 QuestionOptionView 的位置
                    UIView.animate(withDuration: animationDuration) {
                        guard let view = self.player?.player?.view else { return }
                        self.questionOptionView.snp.makeConstraints { make in
                            make.centerY.equalTo(view).offset(-keyboardHeight / 2)
                        }
                    }
                }
                // 回调，传递键盘状态和高度
                self.onKeyboardVisibilityChanged?(true, keyboardHeight)
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        if isFullScreen {
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
            DispatchQueue.main.async {
                UIView.animate(withDuration: animationDuration) {
                    guard let view = self.player?.player?.view else { return }
                    self.questionOptionView.snp.updateConstraints { make in
                        make.centerY.equalTo(view).offset(8)
                    }
                }
            }
            // 恢复 QuestionOptionView 的位置

            // 回调，传递键盘隐藏状态
            self.onKeyboardVisibilityChanged?(false, 0)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.player?.player?.view.frame = self.view.bounds
            self.mediaControl.frame = self.view.bounds
        }, completion: nil)
    }
    
    private func autoPlayVideo() {
        let config = VideoPlayerConfig.shared

        // 自动播放视频
        if config.getBool(forKey: "autoPlay") {
            player?.play()
        } else {
            player?.pause()
        }
        
        // 自动全屏播放视频
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.66) {
//            if config.getBool(forKey: "autoFullScreenPlay") {
//                NotificationCenter.default.post(name: .toggleFullScreen, object: nil)
//            }
            
            // 记住弹窗的开关状态
            self.barrageController.isStop = config.getBool(forKey: "rememberPopupState")
            
            // 启用便捷操作弹幕
            if config.getBool(forKey: "bulletScreenQuickOperation") {
                // 实现便捷操作弹幕的逻辑
            }
            
            // 使用推荐的弹幕字体
            if config.getBool(forKey: "bulletScreenRecommendedFont") {
                // 设置推荐的弹幕字体
                self.barrageController.defaultColor = UIColor.yellow
            }
            
            // 启用重力感应旋转屏幕
            if config.getBool(forKey: "enableGravityRotation") {
                // 实现重力感应旋转屏幕的逻辑
            }
            
            // 退出播放时自动小窗播放
            if config.getBool(forKey: "autoPipOnExit") {
                // 实现退出播放时自动小窗播放的逻辑
            }
        }
    }
    
    private func setupSegmentedView() {
        segmentedView.delegate = self
        let indicator = JXSegmentedIndicatorLineView()
        segmentedView.indicators = [indicator]
        segmentedView.backgroundColor = .white
        segmentedDtaSource = PlayerSegmentedTitleDataSource()
        segmentedView.dataSource = segmentedDtaSource
        segmentedView.listContainer = listContainerView
    }
    
    private func setupMediaControl() {
        mediaControl = IJKMediaControl()
    }
    
    func updateSubtitles(with aiCaptionsVOS: [AICaption]) {
        subtitleView.updateSubtitles(with: aiCaptionsVOS)
    }
    
    func updateCurrentPlaybackTime(_ currentTime: TimeInterval) {
        subtitleView.updateCurrentTime(currentTime)
        subtitleView.onHeightUpdated = { height in
            self.subtitleView.snp.updateConstraints { make in
                make.height.equalTo(height)
            }
        }
        adverView.updateCurrentTime(currentTime)
        questionOptionView.updateCurrentTime(currentTime)
        videoTitlesView.updateCurrentTime(currentTime, duration: self.player?.player?.duration ?? 100000)
        aiWaterView.updateAIWaterDatas(for: currentTime)
        aiNotesView.currentTimeWorkSelect(with: currentTime)
    }
    
    @objc func backButtonTapped() {
        if self.isFullScreen {
            self.mediaControl.isFullScreen.toggle()
            self.mediaControl.updateViewForFullScreen(self.mediaControl.isFullScreen)
            NotificationCenter.default.post(name: .toggleFullScreen, object: nil)
        } else {
            closePlayer()
            self.viewModel?.endVideoPlayback()
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    private func setupSubViews() {
        courseDetailView = CourseDetailView()
        courseDetailView.cousrInfo = self.viewModel?.courseInfo
        courseDetailView.onTap = { cousrInfo in
            self.viewModel?.courseInfo = cousrInfo
            self.switchVideo(selectedCatelog: cousrInfo.courseCatalogId ?? 1, courseId: cousrInfo.courseInfoId ?? 1)
        }
        commentsView = PlayerCommentsView()
        commentsView.onNewCommentAdded = { [weak self] text in
            self?.viewModel?.addComment(content: text)
        }
        personalNotesView = PersonalNotesView()
        personalNotesView.onNewNoteAdded = { [weak self] in
            self?.player?.player?.pause()
            let editorController = MyRichTextEditorController.init()
            editorController.onTap = { result in
                self?.player?.player?.play()
                self?.viewModel?.addPersonalNote(content: result, noteType: 1, delFileKeys: [], successFileKey: [])
            }
            editorController.cameraButtonCallback = {[weak self] completion in
                let image = self?.mediaControl.captureFrameForIJKPlayer()
                let fileName = "\(UUID().uuidString).png"
                guard let imageData = image?.pngData() else {
                    print("无法将UIImage转换为PNG格式的Data")
                    return
                }
                FileUploadManager().performUpload(uploadFile: "course_video", data: imageData, fileName: fileName, mimeType: "image/png") {result in
                    switch result {
                        case .success(let responseKey):
                        CourseManager().captureVideoFrame(courseInfoId: self?.viewModel?.courseInfo?.courseInfoId ?? 0, videoTime: Int(self?.player?.player?.currentPlaybackTime ?? 0), imageKey: responseKey.data?.fileUrl ?? "") { (frameResult: Result<ApiResponse<String>, Error>) in
                            switch frameResult {
                            case .success(let response):
                                completion(response.data ?? "")
                            case .failure(let error):
                                print("Failed to upload image: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                            print("Failed to upload image: \(error.localizedDescription)")
                    }
                }
            }
            let customBottomSheet = CustomBottomSheetViewController(contentViewController: editorController, height: screenHeight - (self?.segmentedView.frame.minY ?? 320))
            customBottomSheet.modalPresentationStyle = .overFullScreen
            customBottomSheet.modalTransitionStyle = .crossDissolve
            self?.present(customBottomSheet, animated: true, completion: nil)
        }
        aiNotesView = PlayerAINotesView()
        bulletCommentsView = PlayerBulletCommentsView()
        bulletCommentsView.onNewBulletAdded = { [weak self] text, bulletSettings in
            self?.viewModel?.addDanmaku(danmaku: Danmaku(fontColor: bulletSettings.fontColor.rawValue, courseInfoId: self?.viewModel?.courseInfo?.courseInfoId ?? 0, fontSite: bulletSettings.position.rawValue, videoTime: Int(self?.player?.player?.currentPlaybackTime ?? 12), content: text, fontSize: bulletSettings.fontSize.rawValue))
        }
    }
    
    
    
    func updatePlaybackState(_ state: IJKMPMoviePlaybackState) {
        self.mediaControl.refreshMediaControl()
    }
    
    func updateLoadState(_ state: IJKMPMovieLoadState) {
        self.mediaControl.refreshMediaControl()
    }
    
    
    func reloadData() {
        self.viewModel?.fetchDetails()
        self.viewModel?.fetchAllDanmaku()
        segmentedView.defaultSelectedIndex = 0
        segmentedView.reloadData()
        self.courseDetailView.tableView.reloadData()
        self.commentsView.tableView.reloadData()
        self.personalNotesView.tableView.reloadData()
        self.bulletCommentsView.tableView.reloadData()
    }
    
    func switchVideo(selectedCatelog: Int, courseId: Int) {
        self.viewModel?.endVideoPlayback()
        guard let filePath = viewModel?.loadDownloadedFilePath(selectedCatelog: selectedCatelog, courseId: courseId) else {
            viewModel?.getDownloadKeyInfo(selectedCatelog: selectedCatelog, courseId: courseId)
            return
        }
        player?.stop()
        self.mediaControl.delegatePlayer = nil
        self.player?.setupPlayer(with: URL(string: filePath)!)
        mediaControl.updateViewForFullScreen(self.isFullScreen)
        guard let view = self.player?.player?.view else { return }
        self.view.insertSubview(view, at: 0)
        self.player?.player?.view.addSubview(barrageController.view)
        player?.play()
        setupConstraints()
        // 更新其他相关视图和数据
        reloadData()
    }
    
    private func updatePlayerViewConstraints(isFullScreen: Bool) {
        self.player?.player?.view.snp.remakeConstraints { make in
            if isFullScreen {
                make.edges.equalToSuperview()
            } else {
                make.top.equalToSuperview().offset(44)
                make.left.right.equalToSuperview()
                make.height.equalTo(720/1080 * screenHeight)
            }
        }
        self.videoTitlesView.snp.makeConstraints { make in
            make.bottom.equalTo(self.player?.player?.view.snp.bottom ?? 320)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.isFullScreen ?  56: 23)
        }
    }
    
    func setupPlayer(with player: VideoPlayer) {
        self.player = player
        self.player?.delegate = self
    }
    
}

extension VideoPlayerViewController {
    
    @objc private func toggleFullScreen() {
        if isFullScreen {
            exitFullScreen()
        } else {
            enterFullScreen()
        }
        isFullScreen.toggle()
        self.view.layoutIfNeeded()
        self.view.setNeedsLayout()
    }
    
    private func enterFullScreen() {
        if let windowScene = view.window?.windowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .landscapeRight)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
        self.updatePlayerViewConstraints(isFullScreen: true)
        self.segmentedView.isHidden = true
        self.listContainerView.isHidden = true
    }
    
    private func exitFullScreen() {
        if let windowScene = view.window?.windowScene {
            let geometryPreferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: .portrait)
            windowScene.requestGeometryUpdate(geometryPreferences) { error in
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
            }
        }
        self.updatePlayerViewConstraints(isFullScreen: false)
        self.segmentedView.isHidden = false
        self.listContainerView.isHidden = false
    }
}
extension VideoPlayerViewController: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        handleSegmentSelection(at: index)
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didClickSelectedItemAt index: Int) {
//        handleSegmentSelection(at: index)
//        self.segmentedView(<#T##segmentedView: JXSegmentedView##JXSegmentedView#>, scrollingFrom: <#T##Int#>, to: <#T##Int#>, percent: <#T##CGFloat#>)
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didScrollSelectedItemAt index: Int) {
        handleSegmentSelection(at: index)
    }
    
    private func handleSegmentSelection(at index: Int) {
        switch index {
        case 0:
            viewModel?.fetchDetails()
        case 1:
            viewModel?.fetchComments(page: 0, size: 20)
        case 2:
            viewModel?.fetchPersonalNotes(page: 0, size: 20)
        case 3:
            viewModel?.fetchAINotes()
        case 4:
            viewModel?.fetchAllDanmaku()
        default:
            break
        }
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percent: CGFloat) {
        // Handle scrolling logic if necessary
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        return true
    }
}


extension VideoPlayerViewController: JXSegmentedListContainerViewDataSource {
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return VideoSubViewType.allCases.count
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        switch VideoSubViewType.allCases[index] {
        case .comments:
            return commentsView
        case .personalNotes:
            return personalNotesView
        case .aiNotes:
            return aiNotesView
        case .bulletComments:
            return bulletCommentsView
        case .courseDetail:
            return courseDetailView
        }
    }
}

extension VideoPlayerViewController: IJKMediaControlDelegate {
    
    func getCaptionImage(image: UIImage) {
        // 将UIImage转换为Data
        guard let imageData = image.pngData() else {
            print("无法将UIImage转换为PNG格式的Data")
            return
        }
    }
    
    func currentPlaybackTimeDidChange(_ currentTime: TimeInterval) {
        updateCurrentPlaybackTime(currentTime)
        
    }
    func didTapButton(action: MediaControlAction) {
        removeVideoControlsView()
        let playerView = self.player?.player?.view
        switch action {
        case .speed:
            let control = createOrUpdateVideoControlsView(withFrame: CGRect(x: screenWidth - 140, y: 0, width: 140, height: screenHeight), controlsTypes: .speed)
            playerView?.addSubview(control)
            control.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(140)
            }
            control.reloadData()
            control.onCellSelected = { indexPath in
                control.removeFromSuperview()
            }
            // 处理倍速逻辑
        case .aspectRatio:
            let control = createOrUpdateVideoControlsView(withFrame: CGRect(x: screenWidth - 140, y: 0, width: 140, height: screenHeight), controlsTypes: .aspectRatio)
            playerView?.addSubview(control)
            control.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(140)
            }
            control.reloadData()
            control.onCellSelected = { indexPath in
                control.removeFromSuperview()
            }
        case .selectTrack:
            guard let courseInfos = self.viewModel?.onlineCoursesResponse?.courseInfos else { return }
            let control = createOrUpdateVideoControlsView(withFrame: CGRect(x: screenWidth - 270, y: 0, width: 270, height: screenHeight), controlsTypes: .tracks, courseInfos: courseInfos)
            playerView?.addSubview(control)
            control.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(270)
            }
            control.reloadData()
            control.onCellSelected = { indexPath in
                control.removeFromSuperview()
            }
            control.onTrackSelected = {courseInfo in
                self.viewModel?.courseInfo = courseInfo
                guard let courseCatalogId = courseInfo.courseCatalogId, let courseInfoId = courseInfo.courseInfoId else { return }
                self.switchVideo(selectedCatelog: courseCatalogId, courseId: courseInfoId)
            }
            // 处理选择轨道逻辑
        case .captureFrame:
            if let window = UIApplication.shared.currentKeyWindow {
                window.makeToast("截图完成")
            }
        case .toggleDanmaku:
            if self.barrageController.isStop == true {
                self.barrageController.startBarrage()
            } else {
                self.barrageController.stopBarrage()
            }
            
            print("Toggle Danmaku button tapped")
            // 处理弹幕显示和隐藏逻辑
        case .aiCaption:
            /// 处理字幕
            let control =  createOrUpdateVideoControlsView(withFrame: CGRect(x: screenWidth - 240, y: 0, width: 240, height: screenHeight), controlsTypes: .aiCaption)
            control.controlsTypes = .aiCaption
            playerView?.addSubview(control)
            
            control.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(200)
            }
            control.reloadData()
            control.onCaptionsSelected = { isOPen in
                if isOPen {
                    self.subtitleView.isHidden = false
                } else {
                    self.subtitleView.isHidden = true
                }
            }
            control.onCellSelected = { _ in
                control.removeFromSuperview()
            }
        case .titleButton:
            break
            //            self.videoTitlesView.isHidden.toggle()
        }
    }
    
    private func createOrUpdateVideoControlsView(withFrame frame: CGRect, controlsTypes: VideoControlsType, courseInfos: [CourseInfo]? = nil) -> VideoControlsView {
        let playerView = self.player?.player?.view

            // 创建新的 VideoControlsView
        videoControlsView = VideoControlsView(frame: frame, cousreInfos: courseInfos ?? [],selectedCousreInfoId: self.viewModel?.courseInfo?.courseInfoId ?? 1, controlsTypes: controlsTypes)
            videoControlsView?.delegate = self.mediaControl
            playerView?.addSubview(videoControlsView!)
            
            videoControlsView?.snp.makeConstraints { make in
                make.top.bottom.right.equalToSuperview()
                make.width.equalTo(frame.width)
            }
        return videoControlsView!
    }
    
    private func removeVideoControlsView() {
        videoControlsView?.removeFromSuperview()
        videoControlsView = nil
    }
}
