//
//  IMManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

// MARK: - IMManager

class IMManager {
    let networkManager: NetworkManager<IMService>
    
    init() {
        networkManager = NetworkManager<IMService>()
    }
    
    func initializeIM(completion: @escaping (Result<ApiResponse<IMInitResponse>, Error>) -> Void) {
        networkManager.request(target: .initializeIM) { (result: Result<ApiResponse<IMInitResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

/***
 let imManager = IMManager()

 // 初始化IM
 imManager.initializeIM { result in
     switch result {
     case .success(let response):
         print("IM initialized successfully: \(response.data)")
     case .failure(let error):
         print("Failed to initialize IM: \(error)")
     }
 }

 // 获取IM秘钥
 imManager.getIMSecretKey { result in
     switch result {
     case .success(let response):
         print("IM secret key: \(response.data.secretKey)")
     case .failure(let error):
         print("Failed to get IM secret key: \(error)")
     }
 }

 // 处理IM回调
 let callbackData: [String: Any] = ["event": "message", "content": "Hello, world!"]
 imManager.imCallback(data: callbackData) { result in
     switch result {
     case .success(let response):
         if response.data.success {
             print("IM callback processed successfully")
         } else {
             print("IM callback processing failed: \(response.data.message ?? "Unknown error")")
         }
     case .failure(let error):
         print("Error processing IM callback: \(error)")
     }
 }

**/
