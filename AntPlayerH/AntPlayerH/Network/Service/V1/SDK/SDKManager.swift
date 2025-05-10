//
//  SDKManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

class SDKManager {
    let networkManager: NetworkManager<SDKService>
    
    init() {
        networkManager = NetworkManager<SDKService>()
    }
    
    func initializeSDK(accesskey: String? = nil, completion: @escaping (Result<ApiResponse<SDKInitResponse>, Error>) -> Void) {
        networkManager.request(target: .initializeSDK(accesskey: accesskey)) { (result: Result<ApiResponse<SDKInitResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getSDKErrorMessage(errorCode: Int, completion: @escaping (Result<ApiResponse<String>, Error>) -> Void) {
        networkManager.request(target: .getSDKErrorMessage(errorCode: errorCode)) { (result: Result<ApiResponse<String>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}
