//
//  InteractionService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

// MARK: - InteractionService

enum InteractionService {
    case getAllDanmaku(courseInfoId: Int)
    case addDanmaku(danmaku: Danmaku)
    case answerQuestion(questionShowUuid: String, answer: String)
}

extension InteractionService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .getAllDanmaku:
            return "/biz/courseBarrage/getByCourseInfo"
        case .addDanmaku:
            return "/biz/courseBarrage/addToStudent"
        case .answerQuestion:
            return "/biz/questionAnswerRecord/answer"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .getAllDanmaku(let courseInfoId):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId], encoding: JSONEncoding.default)
        case .addDanmaku(let danmaku):
            return .requestJSONEncodable(danmaku)
        case .answerQuestion(let questionShowUuid, let answer):
            return .requestParameters(parameters: ["questionShowUuid": questionShowUuid, "answer": answer], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Models

struct Danmaku: Codable {
    let fontColor: String
    let courseInfoId: Int
    let fontSite: Int
    let videoTime: Int
    let content: String
    let fontSize: Int
}

struct DanmakuResponse: Codable {
    let id: Int
    let idCode: String
    let remark: String?
    let page: Int
    let size: Int
    let courseCatalogId: Int?
    let courseCatalogName: String?
    let courseType: String?
    let courseInfoId: Int
    let courseInfoName: String?
    let usernameVirtual: String
    let avatarVirtual: String
    let userId: Int
    let userName: String?
    let merchantId: Int
    let merchantName: String?
    let commentStatus: Int
    let virtualed: Bool
    let content: String
    let videoTime: Int
    let fontSize: Int
    let fontColor: String?
    let fontSite: Int
    let contentTime: String
    let order: String?
    let videoTimeStr: String?
    let avatar: String?
    let msgType: Int
}

struct AnswerQuestionResponse: Codable {
    let success: Bool?
}


