//
//  FeedbackViewModel.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//
import Foundation
import UIKit

class FeedbackViewModel {
    private let feedbackManager: FeedbackManager
    private let fileManger: FileUploadManager

    var feedbackOptions: [FeedbackOptionViewModel] = []
    var images: [UIImage] = []
    var feedbackText: String = ""
    var contactInfo: String = ""
    var isSubmitting: Bool = false
    var errorMessage: String?
    
    var onStateChanged: (() -> Void)?
    
    init(feedbackManager: FeedbackManager = FeedbackManager(), fileManger: FileUploadManager = FileUploadManager()) {
        self.feedbackManager = feedbackManager
        self.fileManger = fileManger
        setupFeedbackOptions()
    }
    
    private func setupFeedbackOptions() {
        feedbackOptions = [
            FeedbackOptionViewModel(title: "卡顿，资源占用高或崩溃"),
            FeedbackOptionViewModel(title: "文件无法播放"),
            FeedbackOptionViewModel(title: "文件使用浏览器"),
            FeedbackOptionViewModel(title: "边下边播异常"),
            FeedbackOptionViewModel(title: "没有想要的功能"),
            FeedbackOptionViewModel(title: "画面、声音、字幕异常"),
            FeedbackOptionViewModel(title: "其他建议")
        ]
    }
    
    func submitFeedback() {
        isSubmitting = true
        
        if !images.isEmpty {
            uploadImages { [weak self] fileKeys in
                self?.submitFeedbackWithFileKeys(fileKeys)
            }
        } else {
            submitFeedbackWithFileKeys([])
        }
    }
    
    private func submitFeedbackWithFileKeys(_ fileKeys: [String]) {
        errorMessage = nil
        onStateChanged?()
        
        let selectedOptions = feedbackOptions.filter { $0.isSelected }.map { $0.title }.joined(separator: ", ")
        let adviseTitle = selectedOptions.isEmpty ? nil : selectedOptions
        feedbackManager.addFeedback(adviseContent: feedbackText, adviseTitle: adviseTitle, contactWay: contactInfo, sucessFileKey: fileKeys) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSubmitting = false
                
                switch result {
                case .success:
                    self?.onStateChanged?()
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func uploadImages(completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var fileKeys: [String] = []
        
        for (index, image) in images.enumerated() {
            dispatchGroup.enter()
            
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                dispatchGroup.leave()
                continue
            }
            
            let fileName = "image_\(index).jpg"
            fileManger.performUpload(uploadFile: "user_advice_feedback", data: imageData, fileName: fileName, mimeType: "image/jpeg") { result in
                switch result {
                case .success(let fileKey):
                    fileKeys.append(fileKey.data?.fileKey ?? "")
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(fileKeys)
        }
    }
}

class FeedbackOptionViewModel {
    let title: String
    var isSelected: Bool {
        didSet {
            onStateChanged?()
        }
    }
    
    var onStateChanged: (() -> Void)?
    
    init(title: String, isSelected: Bool = false) {
        self.title = title
        self.isSelected = isSelected
    }
    
    func toggleSelection() {
        isSelected = !isSelected
    }
}

