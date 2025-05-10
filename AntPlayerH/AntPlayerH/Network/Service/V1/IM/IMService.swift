//
//  IMService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

enum IMService {
    case initializeIM
}

extension IMService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .initializeIM:
            return "/three/txim/init"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .initializeIM:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .initializeIM:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Response Models

struct IMInitResponse: Codable {
    let secretKey: String?
    let appid: Int32?
}

struct IMSecretKeyResponse: Codable {
    let secretKey: String
}

struct IMCallbackResponse: Codable {
    let success: Bool
    let message: String?
}

