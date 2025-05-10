//
//  InteractionManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
// MARK: - InteractionManager
import Moya

class InteractionManager {
    let networkManager: NetworkManager<InteractionService>
    
    init() {
        networkManager = NetworkManager<InteractionService>()
    }
    
    func getAllDanmaku(courseInfoId: Int, completion: @escaping (Result<ApiResponse<[DanmakuResponse]>, Error>) -> Void) {
        networkManager.request(target: .getAllDanmaku(courseInfoId: courseInfoId)) { (result: Result<ApiResponse<[DanmakuResponse]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func addDanmaku(danmaku: Danmaku, completion: @escaping (Result<ApiResponse<EmptyResponse>, Error>) -> Void) {
        networkManager.request(target: .addDanmaku(danmaku: danmaku)) { (result: Result<ApiResponse<EmptyResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func answerQuestion(questionShowUuid: String, answer: String, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .answerQuestion(questionShowUuid: questionShowUuid, answer: answer)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

/**
 
 let interactionManager = InteractionManager()

 // 获取所有弹幕
 interactionManager.getAllDanmaku(courseInfoId: 16) { result in
     switch result {
     case .success(let response):
         print("Danmaku list: \(response.data)")
     case .failure(let error):
         print("Failed to get danmaku list: \(error)")
     }
 }

 // 添加弹幕信息
 let danmaku = Danmaku(fontColor: "#666666", courseInfoId: 16, fontSite: 46, videoTime: 41, content: "exercitation mollit occaecat", fontSize: 44)
 interactionManager.addDanmaku(danmaku: danmaku) { result in
     switch result {
     case .success(let response):
         print("Danmaku added successfully")
     case .failure(let error):
         print("Failed to add danmaku: \(error)")
     }
 }

 // 回答问题
 interactionManager.answerQuestion(questionShowUuid: "string", answer: "string") { result in
     switch result {
     case .success(let response):
         print("Question answered successfully: \(response.data)")
     case .failure(let error):
         print("Failed to answer question: \(error)")
     }
 }
 
 */
