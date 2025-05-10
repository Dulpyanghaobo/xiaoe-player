//
//  VideoViewModel.swift
//  AntPlayerH
//
//  Created by i564407 on 7/26/24.
//
import Foundation

class VideoViewModel {
    
    private var timer: Timer?
    private var startTime: Date?
    private var pauseDuration: TimeInterval = 0
    private var isPaused: Bool = false
    private var totalDuration: TimeInterval = 0
    weak var delegate: VideoViewModelDelegate?
    
    private let commentManager = CommentNoteManager()
    private let courseManager = CourseManager()
    private let interactionManager = InteractionManager()
    var onlineCoursesResponse: OnlineCoursesResponse?
    var videoExtensionResponse: [VideoExtensionResponse?]?
    var videoPlayInitResponse: VideoPlayInitResponse?
    var fileDownloadManager = FileDownloadManager.init()
    var courseInfo: CourseInfo?
    
    init(onlineCoursesResponse: OnlineCoursesResponse, courseInfo: CourseInfo) {
        self.onlineCoursesResponse = onlineCoursesResponse
        self.courseInfo = courseInfo
        initCourseDetail(onlineCourseResponse: onlineCoursesResponse)
    }
    
    func initCourseDetail(onlineCourseResponse: OnlineCoursesResponse) {
        self.onlineCoursesResponse = onlineCourseResponse
    }
    
    func fetchComments(page: Int, size: Int) {
        commentManager.getCourseComments(courseInfoId: self.courseInfo?.courseInfoId ?? 0, page: page, size: size) { result in
            switch result {
            case .success(let response):
                guard let records = response.data?.records else { return }
                self.delegate?.didFetchComments(records)
            case .failure(let error):
                print("Failed to fetch comments: \(error)")
            }
        }
    }
    
    func fetchPersonalNotes(page: Int, size: Int) {
        commentManager.getPersonalNotes(courseInfoId: self.courseInfo?.courseInfoId ?? 11, page: page, size: size) { result in
            switch result {
            case .success(let response):
                guard let records = response.data?.records else { return }
                self.delegate?.didFetchPersonalNotes(records)
            case .failure(let error):
                print("Failed to fetch personal notes: \(error)")
            }
        }
    }
    
    func fetchAINotes() {
        commentManager.getAINotes(id: 11) { result in
            switch result {
            case .success(let response):
                guard let details = response.data else { return }
                self.delegate?.didFetchAINotes(details)
            case .failure(let error):
                print("Failed to fetch AI notes: \(error)")
            }
        }
    }
    
    func addComment(content: String) {
        commentManager.addComment(courseInfoId: self.courseInfo?.courseInfoId ?? 0, courseCatalogId: self.onlineCoursesResponse?.courseCatalogId ?? 0, content: content) { result in
            switch result {
            case .success(let response):
                guard let details = response.data else { return }
                self.delegate?.didAddComment(details)
            case .failure(let error):
                print("Failed to add comment: \(error)")
            }
        }
    }
    
    func likeComment(courseCommentId: Int, like: Bool) {
        commentManager.likeComment(courseCommentId: courseCommentId, like: like) { result in
            switch result {
            case .success(let response):
                guard let details = response.data else { return }
                self.delegate?.didLikeComment(details)
            case .failure(let error):
                print("Failed to like comment: \(error)")
            }
        }
    }
    
    func modifyNote(id: Int, content: String, noteType: Int, delFileKeys: [String], successFileKey: [String]) {
        commentManager.modifyNote(id: id, content: content, noteType: noteType, delFileKeys: delFileKeys, sucessFileKey: successFileKey) { result in
            switch result {
            case .success(let response):
                guard let details = response.data else { return }
                self.delegate?.didModifyNote(details)
            case .failure(let error):
                print("Failed to modify note: \(error)")
            }
        }
    }
    
    func addPersonalNote(content: String, noteType: Int, delFileKeys: [String], successFileKey: [String]) {
        commentManager.addPersonalNote(courseInfoId: self.courseInfo?.courseInfoId ?? 0, content: content, noteType: noteType, delFileKeys: delFileKeys, sucessFileKey: successFileKey) { result in
            switch result {
            case .success(let response):
                guard let details = response.data else { return }
                self.delegate?.didAddPersonalNote(details)
            case .failure(let error):
                print("Failed to add personal note: \(error)")
            }
        }
    }
    
    func getVideoExt() {
        courseManager.initializeVideoPlay(courseInfoId: self.courseInfo?.courseInfoId ?? 0) { result in
            switch result {
            case .success(let response):
                self.courseManager.initializeVideoPlayExt(playRecordUuid: response.data?.playRecordUuid ?? "",courseInfoId: self.courseInfo?.courseInfoId ?? 0) { result in
                    
                }
            case .failure(let error):
                break
            }
        }
        
    }
    
    
    // 添加其他数据请求方法，例如课程详情
    func fetchDetails() {
        let dispatchGroup = DispatchGroup()
        var courseDirectoryPlayInfoResponse: CourseDirectoryPlayInfoResponse?
        var merchantBaseInfoResponse: MerchantBaseInfoResponse?
        var videoExtensionResponse: [VideoExtensionResponse?]?
        var videoPlayInitResponse: VideoPlayInitResponse?
        guard let courseCatalogId = self.onlineCoursesResponse?.courseCatalogId, let onlineCoursesResponse = self.onlineCoursesResponse else { return }
        
        
        var courseDirectoryError: Error?
        var merchantBaseInfoError: Error?

        dispatchGroup.enter()
        courseManager.getCourseDirectoryPlayInfo(courseCatalogId: courseCatalogId) { result in
            switch result {
            case .success(let response):
                courseDirectoryPlayInfoResponse = response.data
            case .failure(let error):
                courseDirectoryError = error
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        courseManager.getMerchantBaseInfo { result in
            switch result {
            case .success(let response):
                merchantBaseInfoResponse = response.data
            case .failure(let error):
                merchantBaseInfoError = error
            }
            dispatchGroup.leave()
        }
        

        if let courseInfos = self.onlineCoursesResponse?.courseInfos {
            dispatchGroup.enter()
            let ids = courseInfos.map { info in
                return info.courseInfoId!
            }
            courseManager.getPlayList(courseCatalogId: self.onlineCoursesResponse?.courseCatalogId, courseInfoIds: ids, completion:{ result in
                switch result {
                case .success(let response):
                    print("\(response)")
                case .failure(let error):
                    print("\(error)")
                }
                dispatchGroup.leave()
            })
        }

        
        dispatchGroup.enter()
        courseManager.initializeVideoPlay(courseInfoId: self.courseInfo?.courseInfoId ?? 0) { result in
            switch result {
            case .success(let response):
                dispatchGroup.enter()
                self.startTimer()
                self.courseManager.initializeVideoPlayExt(playRecordUuid: response.data?.playRecordUuid ?? "",courseInfoId: self.courseInfo?.courseInfoId ?? 0) { result in
                    switch result {
                    case .success(let response):
                        videoPlayInitResponse = response.data
                    case .failure(let error):
                        courseDirectoryError = error
                    }
                    dispatchGroup.leave()
                }
            case .failure(let error):
                break
            }
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
            self.videoPlayInitResponse = videoPlayInitResponse
            self.videoExtensionResponse = videoExtensionResponse
            if let courseDirectoryPlayInfoResponse = courseDirectoryPlayInfoResponse, let merchantBaseInfoResponse = merchantBaseInfoResponse, let videoPlayInitResponse = self.videoPlayInitResponse {
                // 将两个响应传递出去
                self.delegate?.didFetchCourseDetails(courseDirectoryPlayInfoResponse, courseResponse: onlineCoursesResponse, merchantBaseInfoResponse: merchantBaseInfoResponse, videoPlayInitResponse: videoPlayInitResponse)
            } else {
                // 处理错误情况
                print("Failed to fetch course details or merchant base info")
                if let error = courseDirectoryError {
                    print("Course Directory Error: \(error)")
                }
                if let error = merchantBaseInfoError {
                    print("Merchant Base Info Error: \(error)")
                }
            }
        }
    }
    
    
    //记录视频播放时间
    func recordVideoPlay(playRecordUuid: String,
                         playStart: String,
                         playEnd: String,
                         playVideoStart: Int,
                         playVideoEnd: Int,
                         playVideoMaxTime: Int,
                         duration: Int) {
        courseManager.recordVideoPlay(playRecordUuid: playRecordUuid, playStart: playStart, playEnd: playEnd, playVideoStart: playVideoStart, playVideoEnd: playVideoEnd, playVideoMaxTime: playVideoMaxTime, duration: duration) { result in
            switch result {
            case .success(let response):
                break
            case .failure(let error):
                print("Failed to fetch danmaku: \(error)")
            }
        }
    }
    
    
    // 弹幕相关方法
    func fetchAllDanmaku() {
        interactionManager.getAllDanmaku(courseInfoId: self.courseInfo?.courseInfoId ?? 0) { result in
            switch result {
            case .success(let response):
                guard let danmakuList = response.data else { return }
                self.delegate?.didFetchDanmaku(danmakuList)
            case .failure(let error):
                print("Failed to fetch danmaku: \(error)")
            }
        }
    }

    func addDanmaku(danmaku: Danmaku) {
        interactionManager.addDanmaku(danmaku: danmaku) { result in
            switch result {
            case .success:
                self.delegate?.didAddDanmaku(true)
            case .failure(let error):
                print("Failed to add danmaku: \(error)")
                self.delegate?.didAddDanmaku(false)
            }
        }
    }

    func answerQuestion(questionShowUuid: String, answer: String) {
        interactionManager.answerQuestion(questionShowUuid: questionShowUuid, answer: answer) { result in
            switch result {
            case .success(let response):
                guard let answerResponse = response.data else {
                    self.delegate?.didAnswerQuestion(false)
                    return
                }
                self.delegate?.didAnswerQuestion(answerResponse)
            case .failure(let error):
                print("Failed to answer question: \(error)")
                DispatchQueue.main.async {
                    if let window = UIApplication.shared.currentKeyWindow {
                        window.makeToast("\(error.localizedDescription)")
                    }
                    self.delegate?.didAnswerQuestion(false)
                    
                }

            }
        }
    }
    
    private func startTimer() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if !self.isPaused {
                self.totalDuration += 1
            }
        }
    }
    
    func pauseVideoPlayback() {
        isPaused = true
        pauseDuration += Date().timeIntervalSince(startTime ?? Date())
        // Handle other pause events (e.g., showing questions, ads)
    }
    
    func resumeVideoPlayback() {
        isPaused = false
        startTime = Date()
    }
    
    func endVideoPlayback() {
        timer?.invalidate()
        timer = nil
        
        // Prepare data for recording
        guard let playRecordUuid = self.videoPlayInitResponse?.playRecordUuid else { return  }
        let playStartTimestamp = startTime?.timeIntervalSince1970 ?? 0
        let playEndTimestamp = Date().timeIntervalSince1970
        let playStart = convert_timestamp_to_string(playStartTimestamp)
        let playEnd = convert_timestamp_to_string(playEndTimestamp)
        
        // Call the record function
        recordVideoPlay(playRecordUuid: playRecordUuid,
                        playStart: playStart,
                        playEnd: playEnd,
                        playVideoStart: 0,
                        playVideoEnd: Int(totalDuration),
                        playVideoMaxTime: Int(totalDuration),
                        duration: Int(totalDuration - pauseDuration))
    }
    
    func convert_timestamp_to_string(_ timestamp: TimeInterval) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
    
    func getDownloadKeyInfo(selectedCatelog: Int, courseId: Int) {
        courseManager.getDownloadKeyInfo(courseId: courseId) { [weak self] result in
            switch result {
            case .success(let response):
                if let url = response.data?.fileUrl {
                    self?.fileDownloadManager.startDownload(urlStr: url)
                }
                self?.fileDownloadManager.totalStart()
                self?.fileDownloadManager.onDownloadComplete = { success, filePath, totalCount in
                    if success {
                        self?.courseManager.downloadCallback(courseInfoId: courseId, downloadStatus: 1, percentTransferred: 1, predeductId: 0, transferredBytes: totalCount) { result in
                            switch result {
                            case .success(let response):
                                print("Download callback success: \(response)")
                            case .failure(let error):
                                print("Download callback failed: \(error)")
                            }
                        }
                        self?.saveDownloadedFilePath(selectedCatelog: selectedCatelog, courseId: courseId, filePath: filePath ?? "")
                    }
                    
                }
            case .failure(let error): break
            }
        }
    }
    
    
    private func saveDownloadedFilePath(selectedCatelog: Int, courseId: Int, filePath: String) {
        var downloadedCourses = UserDefaults.standard.dictionary(forKey: "downloadedCourses") as? [String: String] ?? [:]
        downloadedCourses["course_\(selectedCatelog)_\(courseId)"] = filePath
        UserDefaults.standard.set(downloadedCourses, forKey: "downloadedCourses")
    }
    
    func loadDownloadedFilePath(selectedCatelog: Int, courseId: Int) -> String? {
        let downloadedCourses = UserDefaults.standard.dictionary(forKey: "downloadedCourses") as? [String: String]
        self.fileDownloadManager.validateFile(at: downloadedCourses?["course_\(selectedCatelog)_\(courseId)"] ?? "") { isValid in
            DispatchQueue.main.async {
                if isValid {
                    print("File is valid and playable.")
                    // Handle playable file
                } else {
                    print("File is not valid or not playable.")
                    // Handle invalid file
                }
            }
        }

        return self.fileDownloadManager.getFullPath(for: downloadedCourses?["course_\(selectedCatelog)_\(courseId)"])
    }
    
    
}

protocol VideoViewModelDelegate: AnyObject {
    func didFetchComments(_ comments: [CommentRecord])
    func didFetchPersonalNotes(_ notes: [NoteRecord])
    func didFetchAINotes(_ aiNotes: [AINoteResponse])
    func didAddComment(_ message: Bool)
    func didLikeComment(_ success: Bool)
    func didModifyNote(_ success: Bool)
    func didAddPersonalNote(_ success: Bool)
    func didFetchCourseDetails(_ details: CourseDirectoryPlayInfoResponse, courseResponse: OnlineCoursesResponse, merchantBaseInfoResponse: MerchantBaseInfoResponse, videoPlayInitResponse: VideoPlayInitResponse)
    // 新增的弹幕和回答问题的代理方法
    func didFetchDanmaku(_ danmaku: [DanmakuResponse])
    func didAddDanmaku(_ success: Bool)
    func didAnswerQuestion(_ success: Bool)
}
