//
//  AdManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

class AdManager {
    let networkManager: NetworkManager<AdService>
    
    init() {
        networkManager = NetworkManager<AdService>()
    }
    
    func addAdData(adId: String, action: String, completion: @escaping (Result<ApiResponse<AdDataResponse>, Error>) -> Void) {
        networkManager.request(target: .addAdData(adId: adId, action: action)) { (result: Result<ApiResponse<AdDataResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

