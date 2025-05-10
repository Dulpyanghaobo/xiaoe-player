//
//  FeedbackService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//
import Foundation
import Moya

enum FeedbackService {
    case addFeedback(adviseContent: String, adviseTitle: String?, contactWay: String?, sucessFileKey: [String]?)
    case reportFeedback(content: String, deviceKey: String?, loginKey: String?, softwareType: String?)
}

extension FeedbackService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .addFeedback:
            return "/biz/userAdvise/add"
        case .reportFeedback:
            return "/biz/feedbackMsg/feedback"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .addFeedback(let adviseContent, let adviseTitle, let contactWay, let sucessFileKey):
            var parameters: [String: Any] = ["adviseContent": adviseContent]
            if let adviseTitle = adviseTitle { parameters["adviseTitle"] = adviseTitle }
            if let contactWay = contactWay { parameters["contactWay"] = contactWay }
            if let sucessFileKey = sucessFileKey { parameters["sucessFileKey"] = sucessFileKey }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .reportFeedback(let content, let deviceKey, let loginKey, let softwareType):
            var parameters: [String: Any] = ["content": content]
            if let deviceKey = deviceKey { parameters["deviceKey"] = deviceKey }
            if let loginKey = loginKey { parameters["loginKey"] = loginKey }
            if let softwareType = softwareType { parameters["softwareType"] = softwareType }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}

