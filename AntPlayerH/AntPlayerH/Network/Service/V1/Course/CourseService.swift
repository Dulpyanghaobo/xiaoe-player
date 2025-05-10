import Foundation
import Moya
struct CourseLocal {
    let courseUuid: String
    let encryMd5: String
}

enum CourseService {
    case getPublicNotes(courseInfoId: Int, page: Int, size: Int)
    case loadVideoToPlayer(courseList : [CourseLocal])
    case getAllOnlineCourses(order: String)
    case getDownloadKeyInfo(courseId: Int)
    case downloadCallback(courseInfoId: Int, downloadStatus: Int, percentTransferred: Double, predeductId: Int, transferredBytes: Int)
    case searchOnlineCourses(courseName: String)
    case initializeVideoPlayExt(playRecordUuid: String, courseInfoId: Int)
    case initializeVideoPlay(courseInfoId: Int)

    case getCourseDirectoryPlayInfo(courseCatalogId: Int)
    case getMerchantBaseInfo
    case getPlayList(courseCatalogId: Int?, courseInfoIds: [Int])
    case recordVideoPlay(playRecordUuid: String, playStart: String, playEnd: String, playVideoStart: Int, playVideoEnd: Int, playVideoMaxTime: Int, duration: Int)
    case getVideoExtension
    case captureVideoFrame(courseInfoId: Int, videoTime: Int, imageKey: String)
}

extension CourseService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .getPublicNotes:
            return "/biz/courseNote/studentByCourseInfoIdAllOpenNote"
        case .loadVideoToPlayer:
            return "/biz/courseInfo/loadCourseByLocal"
        case .getAllOnlineCourses:
            return "/biz/courseInfo/loadCourseByOnlineCourse"
        case .getDownloadKeyInfo:
            return "/biz/courseInfo/getOnlineCourseUrl"
        case .downloadCallback:
            return "/biz/courseInfo/onlineCourseDownloadCallback"
        case .searchOnlineCourses:
            return "/biz/courseInfo/searchCourseByOnlineCourse"
        case .initializeVideoPlayExt:
            return "/biz/student/playCourseInitExt"
        case .initializeVideoPlay:
            return "/biz/student/playCourseInit"
        case .getCourseDirectoryPlayInfo:
            return "/biz/student/playerGetCourseCatalogById"
        case .getMerchantBaseInfo:
            return "/biz/student/playerGetMerchantInfo"
        case .getPlayList:
            return "/biz/courseInfo/playerListInfo"
        case .recordVideoPlay:
            return "/biz/coursePlayRecord/payRecord"
        case .getVideoExtension:
            return "/biz/courseInfo/getVideoExt"
        case .captureVideoFrame:
            return "/biz/videoCaptureRecord/screenshot"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .getPublicNotes(let courseInfoId, let page, let size):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId, "page": page, "size": size], encoding: JSONEncoding.default)
        case .loadVideoToPlayer(let courses):
            let courseParameters = courses.map { course in
                return [
                    "courseUuid": course.courseUuid,
                    "encryMd5": course.encryMd5
                ]
            }
            let data = try? JSONSerialization.data(withJSONObject: courseParameters, options: [])

            return .requestCompositeData(bodyData: data ?? Data(), urlParameters: [:])
        case .getAllOnlineCourses(let order):
            return .requestParameters(parameters: ["order": order], encoding: JSONEncoding.default)
        case .getDownloadKeyInfo(let courseId):
            return .requestParameters(parameters: ["courseId": courseId], encoding: JSONEncoding.default)
        case .downloadCallback(let courseInfoId, let downloadStatus, let percentTransferred, let predeductId, let transferredBytes):
            return .requestParameters(parameters: [
                "courseInfoId": courseInfoId,
                "downloadStatus": downloadStatus,
                "percent_transferred": percentTransferred,
                "predeductId": predeductId,
                "transferredBytes": transferredBytes
            ], encoding: JSONEncoding.default)
        case .searchOnlineCourses(let courseName):
            return .requestParameters(parameters: ["courseName": courseName], encoding: JSONEncoding.default)
        case .initializeVideoPlayExt(let playRecordUuid, let courseInfoId):
            return .requestParameters(parameters: ["playRecordUuid": playRecordUuid, "courseInfoId": courseInfoId], encoding: JSONEncoding.default)
        case .initializeVideoPlay(let courseInfoId):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId], encoding: JSONEncoding.default)
        case .getCourseDirectoryPlayInfo(let courseCatalogId):
            return .requestParameters(parameters: ["courseCatalogId": courseCatalogId], encoding: JSONEncoding.default)
        case .getMerchantBaseInfo:
            return .requestPlain
        case .getPlayList(let courseCatalogId, let courseInfoIds):
            var parameters: [String: Any] = [:]
            if let courseCatalogId = courseCatalogId {
                parameters["courseCatalogId"] = courseCatalogId
            }
                parameters["courseInfoIds"] = courseInfoIds
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .recordVideoPlay(let playRecordUuid, let playStart, let playEnd, let playVideoStart, let playVideoEnd, let playVideoMaxTime, let duration):
            return .requestParameters(parameters: [
                "playRecordUuid": playRecordUuid,
                "playStart": playStart,
                "playEnd": playEnd,
                "playVideoStart": playVideoStart,
                "playVideoEnd": playVideoEnd,
                "playVideoMaxTime": playVideoMaxTime,
                "duration": duration
            ], encoding: JSONEncoding.default)
        case .getVideoExtension:
            return .requestPlain
        case .captureVideoFrame(let courseInfoId, let videoTime, let imageKey):
            return .requestParameters(parameters: ["courseInfoId": courseInfoId, "videoTime": videoTime, "imageKey": imageKey], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
