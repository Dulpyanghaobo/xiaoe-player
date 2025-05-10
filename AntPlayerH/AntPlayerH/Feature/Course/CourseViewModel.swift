//
//  CourseViewModel.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import Foundation
import AVKit

class CourseViewModel {
    
    private let courseManager = CourseManager()
    var publicNotes: [PublicNotesResponse] = []
    var onlineCourses: [CourseModelWrapper] = []
    var searchCourses: [CourseInfo] = []
    var videoPlayerResponse: VideoPlayerResponse?
    var searchResults: [CourseSearchResult] = []
    var videoExtensionResponse: [VideoExtensionResponse?]?
    var videoPlayInitResponse: VideoPlayInitResponse?
    var courseDirectoryPlayInfo: CourseDirectoryPlayInfoResponse?
    var merchantBaseInfo: MerchantBaseInfoResponse?
    var playList: PlayListResponse?
    var videoExtension: VideoExtensionResponse?
    var fileDownloadManager = FileDownloadManager.init()
    var videoLoader = VideoLoader()
        
    var isLoading: ((Bool) -> Void)?
    var onError: ((Error) -> Void)?
    
    init() {
        self.videoLoader.onError = { error in
            
        }
    }
    
    func addLocalVideos(fromFolder folderName: String, completion: @escaping (Bool) -> Void) {
        // Initiating the process of fetching and validating local videos
        videoLoader.fetchLocalVideos(inFolder: folderName) { [weak self] success in
            guard let self = self else { return }
            if success {
                completion(success)
                print("Local videos validated and added successfully.")
                // Handle the successful addition of local videos
            } else {
                completion(false)
                print("No valid videos were found or added.")
                // Handle the case where no valid videos were added
            }
        }
    }
    
    
    func getDownloadKeyInfo(selectedCatelog: Int, courseId: Int) {
        isLoading?(true)
        courseManager.getDownloadKeyInfo(courseId: courseId) { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let response):
                if let url = response.data?.fileUrl {
                    self?.fileDownloadManager.startDownload(urlStr: url)
                }
                self?.fileDownloadManager.totalStart()
                self?.fileDownloadManager.onDownloadProgress = { progress, predeductId, transferredBytes in

                }
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
            case .failure(let error):
                self?.onError?(error)
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
    
    private func reportDownloadStatus(courseId: Int, status: String) {
        // 实现向后端报告下载状态的逻辑
    }

    func playDownloadedVideo(filePath: String) {

    }
    
    func searchOnlineCourses(courseName: String) {
        isLoading?(true)
        courseManager.searchOnlineCourses(courseName: courseName) { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let response):
                guard let response = response.data else { return }
                self?.searchCourses = response
            case .failure(let error):
                self?.onError?(error)
            }
        }
    }
    
    func getAllOnlineCourses(order: String, completion: @escaping () -> Void) {
        isLoading?(true)
        courseManager.getAllOnlineCourses(order: order) { [weak self] result in
            self?.isLoading?(false)
            switch result {
            case .success(let response):
                guard let response = response.data else { return }
                self?.onlineCourses = response.map { CourseModelWrapper(course: $0)
                }
                completion()
            case .failure(let error):
                self?.onError?(error)
                completion()
            }
        }
    }
}
