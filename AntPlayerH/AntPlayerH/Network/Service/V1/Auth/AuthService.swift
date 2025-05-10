//
//  AuthService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//

import Moya
import Foundation

enum AuthService {
    case login(username: String, password: String, loginKey: String)
    case getPwdKey(userName: String)
    case loginPhoneSms(phone: String)
    case loginPhone(captchaKey: String, username: String, captcha: String)
    case logout
    case bindPhoneSmsCode(phone: String)
    case bindPhone(captcha: String, captchaKey: String, phone: String)
    case getUserSig
    case getRealStatus
    case uploadSfz(type: Int, file: Data)
    case checkFaceStatusByTx
    case checkFaceCallback(orderNo: String)
    case getFaceSdkSign(bizType: Int)
    case getRealSDKSign(nonce: String)
}

extension AuthService {
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
}

extension AuthService: TargetType {
    
    var path: String {
        switch self {
        case .login:
            return "/sys/login"
        case .getPwdKey:
            return "/sys/getPwdKey"
        case .loginPhoneSms:
            return "/sys/loginPhoneSms"
        case .loginPhone:
            return "/sys/loginPhone"
        case .logout:
            return "/sys/logout"
        case .bindPhoneSmsCode:
            return "/sys/user/bindPhoneSmsCode"
        case .bindPhone:
            return "/sys/user/bindPhone"
        case .getUserSig:
            return "/sys/user/getUserSig"
        case .getRealStatus:
            return "/biz/userRealname/getRealStatus"
        case .uploadSfz:
            return "/biz/userRealname/uploadSfz"
        case .checkFaceStatusByTx:
            return "/biz/userRealname/checkFaceStatusByTx"
        case .checkFaceCallback:
            return "/biz/userRealname/checkFaceCallback"
        case .getFaceSdkSign:
            return "/biz/userRealname/getFaceSdkSign"
        case .getRealSDKSign:
            return "/biz/userRealname/getRealSDKSign"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login, .loginPhoneSms, .loginPhone, .logout, .bindPhoneSmsCode, .bindPhone,
             .uploadSfz, .checkFaceCallback, .getFaceSdkSign, .getRealSDKSign:
            return .post
        case .getPwdKey, .getUserSig, .getRealStatus, .checkFaceStatusByTx:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .login(let username, let password, let loginKey):
            let parameters: [String: Any] = [
                "username": username,
                "password": password,
                "loginKey": loginKey
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getPwdKey(let userName):
            return .requestParameters(parameters: ["userName": userName], encoding: URLEncoding.queryString)
        case .loginPhoneSms(let phone):
            return .requestParameters(parameters: ["phone": phone], encoding: JSONEncoding.default)
        case .loginPhone(let captchaKey, let username, let captcha):
            let parameters: [String: Any] = [
                "captchaKey": captchaKey,
                "username": username,
                "captcha": captcha
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .logout:
            return .requestPlain
        case .bindPhoneSmsCode(let phone):
            return .requestParameters(parameters: ["phone": phone], encoding: JSONEncoding.default)
        case .bindPhone(let captcha, let captchaKey, let phone):
            let parameters: [String: Any] = [
                "captcha": captcha,
                "captchaKey": captchaKey,
                "phone": phone
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getUserSig:
            return .requestPlain
        case .uploadSfz(let type, let file):
            let formData = MultipartFormData(provider: .data(file), name: "file", fileName: "sfz.jpg", mimeType: "image/jpeg")
            return .uploadCompositeMultipart([formData], urlParameters: ["type": type])
        case .checkFaceCallback(let orderNo):
            return .requestParameters(parameters: ["orderNo": orderNo], encoding: JSONEncoding.default)
        case .getFaceSdkSign(let bizType):
            return .requestParameters(parameters: ["bizType": bizType], encoding: JSONEncoding.default)
        case .getRealSDKSign(let nonce):
            return .requestParameters(parameters: ["nonce": nonce], encoding: JSONEncoding.default)
        case .getRealStatus, .checkFaceStatusByTx:
            return .requestPlain
        }
    }
}


struct GetPwdKeyResponse: Codable {
    let ik: String
    let iv: String
}

struct LoginResponse: Codable {
    let authorities: [MenuVO]?
    let menus: [String]?
    let playerSdkInfoVO: PlayerSdkInfoVO?
    let roles: [LoginRoleRspVO]?
    let simplicityMenuList: [MenuVO]?
    let studentSettingVO: StudentSettingLoginRspVO?
    let token: String?
    let userInfo: LoginUserVO?
}

struct MenuVO: Codable {
    let color: String?
    let component: String?
    let delFlag: Bool?
    let icon: String?
    let id: Int?
    let idCode: String?
    let isShow: Int?
    let menuName: String?
    let menuPath: String?
    let menuShowType: MenuShowType?
    let menuType: String?
    let orderNum: Int?
    let parentId: Int?
    let perms: String?
    let remark: String?
    let target: String?
}

enum MenuShowType: String, Codable {
    case common
    case full
    case simplified
}

struct PlayerSdkInfoVO: Codable {
    let accessKey: String?
    let initUri: String?
}

struct LoginRoleRspVO: Codable {
    let roleCode: String?
}

struct StudentSettingLoginRspVO: Codable {
    let allowedPcDisplaysNum: Int?
    let allowUnbindDevice: Bool?
    let allowVideoCapture: Bool?
    let audioRepeat: Bool?
    let expireDate: String? // 修改为String类型
    let focePhone: Bool?
    let forceRealname: Bool?
    let id: Int?
    let idCode: String?
    let merchantId: Int?
    let remark: String?
    let studentId: Int?
}

struct LoginUserVO: Codable {
    let activationTime: String? // 修改为String类型
    let avatar: String?
    let bindWechat: Bool?
    let description: String?
    let email: String?
    let expireTime: String? // 修改为String类型
    let id: Int?
    let lastLoginTime: String? // 修改为String类型
    let merchantId: Int?
    let merchantName: String?
    let mobile: String?
    let newPurchase: Bool?
    let realname: String?
    let sex: Int?
    let userIdentity: String?
    let username: String?
    let versionLevel: Int?
}

struct SmsCodeResponse: Codable {
    let data: String?
}

struct PhoneLoginResponse: Codable {
    let token: String
    let userInfo: LoginUserVO
    let menus: [String]?
}

struct RealStatusResponse: Codable {
    let status: Int
    let info: RealStatusInfo?
}

struct RealStatusInfo: Codable {
    let name: String
    let idNum: String
    let viaBase64: String
}

// 上传身份证图片响应模型
struct UploadSfzResponse: Codable {
    let name: String?
    let idNum: String?
}

// 活体识别状态响应模型
// 由于data为null时的情况，可以使用Optional类型
struct CheckFaceStatusResponse: Codable {
    let data: Bool?
}

// 获取SDK签名信息响应模型
struct FaceSdkSignResponse: Codable {
    let faceId: String
    let agreementNo: String
    let openApiAppId: String
    let openApiAppVersion: String
    let openApiNonce: String
    let openApiUserId: String
    let keyLicence: String
    let sign: String
}

// 获取实名SDK签名信息响应模型
struct RealSdkSignResponse: Codable {
    let data: String
}
