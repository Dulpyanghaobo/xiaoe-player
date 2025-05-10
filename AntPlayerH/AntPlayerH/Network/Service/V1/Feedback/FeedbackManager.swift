//
//  FeedbackManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

class FeedbackManager {
    let networkManager: NetworkManager<FeedbackService>
    
    init() {
        networkManager = NetworkManager<FeedbackService>()
    }
    
    func addFeedback(adviseContent: String, adviseTitle: String? = nil, contactWay: String? = nil, sucessFileKey: [String]? = nil, completion: @escaping (Result<ApiResponse<EmptyResponse>, Error>) -> Void) {
        networkManager.request(target: .addFeedback(adviseContent: adviseContent, adviseTitle: adviseTitle, contactWay: contactWay, sucessFileKey: sucessFileKey)) { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func reportFeedback(content: String, deviceKey: String? = nil, loginKey: String? = nil, softwareType: String? = nil, completion: @escaping (Result<ApiResponse<EmptyResponse>, Error>) -> Void) {
        networkManager.request(target: .reportFeedback(content: content, deviceKey: deviceKey, loginKey: loginKey, softwareType: softwareType)) { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

/**
 let feedbackManager = FeedbackManager()

 // 添加意见反馈
 feedbackManager.addFeedback(
     adviseContent: "This is a feedback",
     adviseTitle: "Feedback Title",
     contactWay: "email@example.com",
     sucessFileKey: ["fileKey1", "fileKey2"]
 ) { result in
     switch result {
     case .success(let response):
         print("Feedback added successfully")
     case .failure(let error):
         print("Failed to add feedback: \(error)")
     }
 }

 // 用户反馈上报
 feedbackManager.reportFeedback(
     content: "This is a feedback report",
     deviceKey: "device123",
     loginKey: "login456",
     softwareType: "iOS"
 ) { result in
     switch result {
     case .success(let response):
         print("Feedback reported successfully")
     case .failure(let error):
         print("Failed to report feedback: \(error)")
     }
 }
 
 */
struct EmptyResponse: Codable {}
