//
//  UserService.swift
//  task_management_tool
//
//  Created by i564407 on 4/17/24.
//

import Moya
import Foundation

enum UserService {
    case getUserInfo(userId: String)
    case createUser(name: String, email: String, imageName: String)
}

extension UserService {
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
}

extension UserService: TargetType {
    
    var path: String {
        switch self {
        case .getUserInfo(let userId):
            return "/getUser"
        case .createUser:
            return "/user"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUserInfo:
            return .get
        case .createUser:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getUserInfo(_):
            return .requestPlain  // No parameters for a GET request
        case .createUser(let name, let email, let image):
            return .requestParameters(
                parameters: ["name": name, "email": email, "image": image],
                encoding: JSONEncoding.default  // Encoding to JSON for a POST request
            )
        }
    }
}
