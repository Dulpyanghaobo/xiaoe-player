//
//  AdService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

enum AdService {
    case addAdData(adId: String, action: String)
}

extension AdService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .addAdData:
            return "/ad/add-data"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .addAdData(let adId, let action):
            let parameters: [String: Any] = [
                "adId": adId,
                "action": action
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}

struct AdDataResponse: Codable {
    let success: Bool
    let message: String?
}

