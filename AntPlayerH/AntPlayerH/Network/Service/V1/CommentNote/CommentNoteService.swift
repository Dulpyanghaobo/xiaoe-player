//
//  CommentNoteService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

enum CommentNoteService {
    case addComment(courseInfoId: Int, courseCatalogId: Int?, content: String)
    case getCourseComments(courseInfoId: Int, page: Int, size: Int)
    case likeComment(courseCommentId: Int, like: Bool)
    case getPersonalNoteDetail(id: Int)
    case getPersonalNotes(courseInfoId: Int, page: Int, size: Int)
    case getAINotes(id: Int)
    case modifyNote(id: Int, content: String, noteType: Int, delFileKeys: [String], sucessFileKey: [String])
    case addPersonalNote(courseInfoId: Int, content: String, noteType: Int, delFileKeys: [String], sucessFileKey: [String])
}

extension CommentNoteService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .addComment:
            return "/biz/courseComment/addToStudent"
        case .getCourseComments:
            return "/biz/courseComment/studentGetByCourseInfoId"
        case .likeComment:
            return "/biz/courseComment/studentLikeOrUnlike"
        case .getPersonalNoteDetail:
            return "/biz/courseNote/info"
        case .getPersonalNotes:
            return "/biz/courseNote/studentByCourseInfoIdToMySelf"
        case .getAINotes:
            return "/biz/courseInfo/getAINote"
        case .modifyNote:
            return "/biz/courseNote/edit"
        case .addPersonalNote:
            return "/biz/courseNote/add"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .addComment(let courseInfoId, let courseCatalogId, let content):
            var params: [String: Any] = ["courseInfoId": courseInfoId, "content": content]
            if let catalogId = courseCatalogId {
                params["courseCatalogId"] = catalogId
            }
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case .getCourseComments(let courseInfoId, let page, let size):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId, "page": page, "size": size], encoding: JSONEncoding.default)
        case .likeComment(let courseCommentId, let like):
            return .requestParameters(parameters: ["courseCommentId": courseCommentId, "like": like], encoding: URLEncoding.queryString)
        case .getPersonalNoteDetail(let id):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)
        case .getPersonalNotes(let courseInfoId, let page, let size):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId, "page": page, "size": size], encoding: JSONEncoding.default)
        case .getAINotes(let id):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)
        case .modifyNote(let id, let content, let noteType, let delFileKeys, let sucessFileKey):
            return .requestParameters(parameters: ["id": id, "content": content, "noteType": noteType, "delFileKeys": delFileKeys, "sucessFileKey": sucessFileKey], encoding: JSONEncoding.default)
        case .addPersonalNote(let courseInfoId, let content, let noteType, let delFileKeys, let sucessFileKey):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId, "content": content, "noteType": noteType, "delFileKeys": delFileKeys, "sucessFileKey": sucessFileKey], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}

struct CommentListResponse: Codable {
    let records: [CommentRecord]
    let total: Int
    let size: Int
    let current: Int
    let pages: Int
}

struct CommentRecord: Codable {
    let id: Int
    let content: String
    let userName: String
    let contentTime: String
    let courseTypeDictText: String?
    let courseType: Int
    let courseCatalogId: Int
    let remark: String?
    let merchantName: String
    let likeNum: Int
    let merchantId: Int
    let courseInfoId: Int
    let virtualed: Bool
    let courseInfoName: String
    let courseCatalogName: String
    let idCode: String?
    let avatar: String?
    let userId: Int
    let commentStatus: Int
    let treadNum: Int
    let liked: Bool
    let gzNum: Int
    let page: Int
    
    enum CodingKeys: String, CodingKey {
        case id, content, userName, contentTime, courseTypeDictText = "courseType_dictText", courseType, courseCatalogId, remark, merchantName, likeNum, merchantId, courseInfoId, virtualed, courseInfoName, courseCatalogName, idCode, avatar, userId, commentStatus, treadNum, liked = "likeed", gzNum, page
    }
}

struct NoteDetailResponse: Codable {
    let id: Int
    let content: String
    let courseInfoName: String
    let contentTime: String
    // Add other fields as needed
}

struct NoteListResponse: Codable {
    let maxLimit: Int?
    let pages: Int?
    let size: Int?
    let searchCount: Bool?
    let countId: Int?
    let hitCount: Bool?
    let records: [NoteRecord]?
    let total: Int?
    let current: Int?
    let optimizeCountSql: Bool?
}

struct NoteRecord: Codable {
    let aiContent: String?
    let merchantId: Int?
    let noteType: Int?
    let commentStatus: Int?
    let courseType_dictText: String?
    let courseCatalogName: String?
    let userName: String?
    let idCode: String?
    let courseCatalogId: Int?
    let courseInfoName: String?
    let noteTitle: String?
    let contentTime: String?
    let gzNum: Int?
    let likeNum: Int?
    let merchantName: String?
    let remark: String?
    let content: String
    let courseInfoId: Int?

    let id: Int?
    let courseType: Int?
    let userId: Int?
}

struct AINoteResponse: Codable {
    let endMs: Int?
    let finalSentence: String?
    let sliceSentence: String?
    let speechSpeed: Double?
    let startMs: Int?
    let words: WordsContainer?
    let wordsNum: Int?

    struct WordsContainer: Codable {
        let words: [Word]?

        enum CodingKeys: String, CodingKey {
            case words
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            // Check if it's an array
            if let wordsArray = try? container.decode([Word].self) {
                self.words = wordsArray
            } else {
                // If it's a string, handle it accordingly
                self.words = nil
            }
        }
    }

    struct Word: Codable {
        let offsetEndMs: Int?
        let offsetStartMs: Int?
        let word: String?
    }
}
