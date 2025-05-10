//
//  CourseManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import ObjectiveC

private var isExpandedKey: Bool = false

extension OnlineCoursesResponse {
    var isExpanded: Bool {
        get {
            return objc_getAssociatedObject(self, &isExpandedKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &isExpandedKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class CourseManager {
    let networkManager: NetworkManager<CourseService>
    
    init() {
        networkManager = NetworkManager<CourseService>()
    }
    
    func getPublicNotes(courseInfoId: Int, page: Int, size: Int, completion: @escaping (Result<ApiResponse<[PublicNotesResponse]>, Error>) -> Void) {
        networkManager.request(target: .getPublicNotes(courseInfoId: courseInfoId, page: page, size: size)) { (result: Result<ApiResponse<[PublicNotesResponse]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func loadVideoToPlayer(courseList: [CourseLocal], completion: @escaping (Result<ApiResponse<VideoPlayerResponse>, Error>) -> Void) {
        networkManager.request(target: .loadVideoToPlayer(courseList: courseList)) { (result: Result<ApiResponse<VideoPlayerResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getAllOnlineCourses(order: String, completion: @escaping (Result<ApiResponse<[OnlineCoursesResponse]>, Error>) -> Void) {
        networkManager.request(target: .getAllOnlineCourses(order: order)) { (result: Result<ApiResponse<[OnlineCoursesResponse]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getDownloadKeyInfo(courseId: Int, completion: @escaping (Result<ApiResponse<DownloadKeyInfoResponse>, Error>) -> Void) {
        networkManager.request(target: .getDownloadKeyInfo(courseId: courseId)) { (result: Result<ApiResponse<DownloadKeyInfoResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func downloadCallback(courseInfoId: Int, downloadStatus: Int, percentTransferred: Double, predeductId: Int, transferredBytes: Int, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .downloadCallback(courseInfoId: courseInfoId, downloadStatus: downloadStatus, percentTransferred: percentTransferred, predeductId: predeductId, transferredBytes: transferredBytes)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    
    func searchOnlineCourses(courseName: String, completion: @escaping (Result<ApiResponse<[CourseInfo]>, Error>) -> Void) {
        networkManager.request(target: .searchOnlineCourses(courseName: courseName)) { (result: Result<ApiResponse<[CourseInfo]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func initializeVideoPlay(courseInfoId: Int, completion: @escaping (Result<ApiResponse<VideoPlayInitResponse>, Error>) -> Void) {
        networkManager.request(target: .initializeVideoPlay(courseInfoId: courseInfoId)) { (result: Result<ApiResponse<VideoPlayInitResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    func initializeVideoPlayExt(playRecordUuid: String, courseInfoId: Int, completion: @escaping (Result<ApiResponse<VideoPlayInitResponse>, Error>) -> Void) {
        networkManager.request(target: .initializeVideoPlayExt(playRecordUuid: playRecordUuid, courseInfoId: courseInfoId)) { (result: Result<ApiResponse<VideoPlayInitResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getCourseDirectoryPlayInfo(courseCatalogId: Int, completion: @escaping (Result<ApiResponse<CourseDirectoryPlayInfoResponse>, Error>) -> Void) {
        networkManager.request(target: .getCourseDirectoryPlayInfo(courseCatalogId: courseCatalogId)) { (result: Result<ApiResponse<CourseDirectoryPlayInfoResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getMerchantBaseInfo(completion: @escaping (Result<ApiResponse<MerchantBaseInfoResponse>, Error>) -> Void) {
        networkManager.request(target: .getMerchantBaseInfo) { (result: Result<ApiResponse<MerchantBaseInfoResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getPlayList(courseCatalogId: Int?, courseInfoIds: [Int], completion: @escaping (Result<ApiResponse<[CourseInfo?]>, Error>) -> Void) {
        networkManager.request(target: .getPlayList(courseCatalogId: courseCatalogId, courseInfoIds: courseInfoIds)) { (result: Result<ApiResponse<[CourseInfo?]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func recordVideoPlay(playRecordUuid: String, playStart: String, playEnd: String, playVideoStart: Int, playVideoEnd: Int, playVideoMaxTime: Int, duration: Int, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .recordVideoPlay(playRecordUuid: playRecordUuid, playStart: playStart, playEnd: playEnd, playVideoStart: playVideoStart, playVideoEnd: playVideoEnd, playVideoMaxTime: playVideoMaxTime, duration: duration)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getVideoExtension(completion: @escaping (Result<ApiResponse<[String]>, Error>) -> Void) {
        networkManager.request(target: .getVideoExtension) { (result: Result<ApiResponse<[String]>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func captureVideoFrame(courseInfoId: Int, videoTime: Int, imageKey: String, completion: @escaping (Result<ApiResponse<String>, Error>) -> Void) {
        networkManager.request(target: .captureVideoFrame(courseInfoId: courseInfoId, videoTime: videoTime, imageKey: imageKey)) { (result: Result<ApiResponse<String>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

// Response models (you'll need to define these based on the actual API responses)
struct PublicNotesResponse: Codable {
    let records: [PublicNote]
    let total: Int
    let size: Int
    let current: Int
    let pages: Int
}

struct PublicNote: Codable {
    let courseType_dictText: String?
    let courseCatalogName: String?
    let courseType: Int?
    let idCode: String?
    let courseCatalogId: Int
    let aiContent: String?
    let contentTime: String
    let remark: String?
    let userName: String
    let userId: Int
    let content: String
    let merchantName: String?
    let commentStatus: Int
    let likeNum: Int
    let noteType: Int
    let merchantId: Int
    let courseInfoId: Int
    let gzNum: Int
    let courseInfoName: String
    let id: Int
}

struct VideoPlayerResponse: Codable {
    let courseCatalogId: Int
    let catalogIdCode: String?
    let sort: Int
    let courseType: Int
    let merchantId: Int
    let catalogName: String
    let coverUrl: String?
    let courseNums: Int
    let studentNums: Int
    let playNums: Int
    let courseInfos: [CourseInfo]
}

struct CourseInfo: Codable {
    let courseInfoIdCode: String?
    let courseCatalogId: Int?
    let courseInfoId: Int?
    let sort: Int?
    let courseType: Int?
    let merchantId: Int?
    let courseName: String?
    let courseDesc: String?
    let coverUrl: String?
    let whenLong: Int?
    let videoExt: String?
    let videoSize: Int?
    let videoSizeStr: String?
    let playLastTime: String?
    let videoLastPlayTime: Int?
    let accuPlayDuration: Int?
    let playRate: Int?
    let clientType: String?
}

struct OnlineCoursesResponse: Codable {
    let courseCatalogId: Int?
    let sort: Int?
    let courseType: Int?
    let merchantId: Int?
    let catalogName: String?
    let coverUrl: String?
    let courseNums: Int?
    let studentNums: Int?
    let playNums: Int?
    let courseInfos: [CourseInfo]?
}

struct CourseModelWrapper {
    var course: OnlineCoursesResponse
    var isExpanded: Bool = false
}

struct DownloadKeyInfoResponse: Codable {
    let fileUrl: String
}

struct CourseSearchResult: Codable {
    let courseCatalogId: Int
    let courseInfoId: Int
    let sort: Int
    let courseType: Int
    let merchantId: Int
    let courseName: String
    let courseDesc: String
    let coverUrl: String
    let whenLong: Int
    let videoExt: String
    let videoSize: Int
    let videoSizeStr: String
    let playLastTime: String?
    let videoLastPlayTime: Int
    let accuPlayDuration: Int?
    let playRate: Int
    let clientType: String?
}

 
// Define the struct for the VideoPlayInitResponse
struct VideoPlayInitResponse: Codable {
    let playRecordUuid: String?
    let aiWaterDatas: [AIWaterData]?
    let questionDatas: [QuestionData]?
    let adverDatas: [AdverData]?
    let aiCaptionsVOS: [AICaption]?
    let barrageRspVOS: [BarrageRspVO]?
    let imGroupId: String?
    let courseInfoId: Int?
    let courseContentTitleVOS: [CourseContentTitleVO]?
}

struct CourseContentTitleVO: Codable {
    let text: String?
    let startMs: Int?
    let endMs: Int?
    let sort: Int?
    let durationMs: Int?
}

struct BarrageRspVO: Codable {
    let avatar: String?
    let contentTime: String?
    let content: String?
    let fontSize: Int?
    let remark: String?
    let courseCatalogId: Int?
    let username: String?
    let fontColor: String?
    let usernameVirtual: String?
    let merchantId: Int?
    let videoTime: Int?
    let virtualed: Int?
    let userId: Int?
    let avatarVirtual: String?
    let id: String?
    let fontSite: Int?
    let commentStatus: Int?
    let idCode: String?
    let courseInfoId: Int?
}

// Define the struct for AIWaterData
struct AIWaterData: Codable {
    let videoTime: Int?
    let videoStartTime: Int?
    let videoEndTime: Int?
    let videoEndTimeStr: String?
    let videoStartTimeStr: String?
    let bizData: WatermarkBizData?
}

// Define the struct for WatermarkBizData
struct WatermarkBizData: Codable {
    let watermarkStyle: String?
    let fixedLocation: Int?
    let fixedCustomX: Int?
    let fixedCustomY: Int?
    let marqueeDirectionType: Int?
    let marqueeDirection: Int?
    let marqueeSpeed: Int?
    let marqueeDivision: Int?
    let marqueeLocation: Int?
    let excursion: Int?
    let watermarkType: Int?
    let customerContent: String?
    let imageUrl: String?
    let frontSize: Int?
    let frontColor: String?
    let transparence: Int?
    let duration: Int?
    let intervalNum: Int?
}

// Define the struct for QuestionData
struct QuestionData: Codable, Equatable {
    let videoTime: Int?
    let videoStartTime: Int?
    let videoEndTime: Int?
    let videoEndTimeStr: String?
    let videoStartTimeStr: String?
    let bizData: QuestionBizData?
}

// Define the struct for QuestionBizData
struct QuestionBizData: Codable, Equatable {
    let questionShowUuid: String?
    let questionType: Int?
    let questionTitle: String?
    let answerA: String?
    let answerB: String?
    let answerC: String?
    let answerD: String?
    let answerE: String?
    let calcA: String?
    let calcType: String?
    let url: String?
    let calcB: String?
    let onePlay: Int?
    let twoPlay: Int?
    let threePlay: Int?
    let audioRepeat: Bool?
    let quesAnster: String?
}

// Define the struct for AdverData
struct AdverData: Codable {
    let videoTime: Int?
    let videoStartTime: Int?
    let videoEndTime: Int?
    let videoEndTimeStr: String?
    let videoStartTimeStr: String?
    let bizData: AdBizData?
}

// Define the struct for AdBizData
struct AdBizData: Codable {
    let id: Int?
    let merchantId: Int?
    let adType: Int?
    let adUrl: String?
    let adTitle: String?
    let adAlt: String?
    let targetUrl: String?
}

// Define the struct for AICaption
struct AICaption: Codable {
    let startMs: Int?
    let endMs: Int?
    let text: String?
    let sort: Int?
}

struct CourseDirectoryPlayInfoResponse: Codable {
    let courseCatalogId: Int
    let studentNumbs: Int
    let playNumbs: Int?
    let warnNotice: String
}

struct MerchantBaseInfoResponse: Codable {
    let id: Int
    let idCode: String?
    let remark: String?
    let merchantName: String
    let versionLevel: Int
    let merchantPhoto: String?
    let merchant_intro: String?
    let merchantTeacherQq: String?
    let merchantTeacherPhone: String?
    let merchantTeacherWx: String?
    let courseInfoNumbs: Int?
    let studentNumbs: Int?
}

struct PlayListResponse: Codable {
    let courseCatalogId: Int?
    let courseInfoIds: [Int]?
}

struct VideoExtensionResponse: Codable {
    let videoExt: String
}

