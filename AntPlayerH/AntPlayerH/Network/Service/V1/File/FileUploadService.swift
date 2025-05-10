import Foundation
import Moya

enum FileUploadService {
    case getUploadCredentials(bizCode: String, fileKey: String, fileName: String, fileSize: Int64, lastModifyTime: Int64)
    case uploadFile(bizCode: String, data: Data, fileName: String, mimeType: String)
    case getBizCode
}

extension FileUploadService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .getUploadCredentials:
            return "/sys/attachInfo/uploadCred"
        case .uploadFile:
            return "/sys/common/uploadV2"
        case .getBizCode:
            return "/sys/attachInfo/getBizCode"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUploadCredentials, .uploadFile:
            return .post
        case .getBizCode:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case let .getUploadCredentials(bizCode, fileKey, fileName, fileSize, lastModifyTime):
            let parameters: [String: Any] = [
                "bizCode": bizCode,
                "fileKey": fileKey,
                "fileName": fileName,
                "fileSize": fileSize,
                "lastModifyTime": lastModifyTime
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case let .uploadFile(defaultBizCode, data, fileName, mimeType):
            let formData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName, mimeType: mimeType)
            return .uploadCompositeMultipart([formData], urlParameters: ["bizCode": defaultBizCode])
        case .getBizCode:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadFile:
            return ["Content-Type": "multipart/form-data"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
}
