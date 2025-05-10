//
//  AppConfigService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//
import Foundation
import Moya

enum AppConfigService {
    case initializePlayerConfig
    case getLoginUIConfig
    case getAboutNiudun
    case getAboutApp
    case initializeVersion
    case getAppConfig(typeCode: String)
    case getSoftwareUpgradeInfo(versionKey: String)
}

extension AppConfigService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .initializePlayerConfig:
            return "/biz/student/playerInitConfig"
        case .getLoginUIConfig:
            return "/sys/sysConfig/playerGetLoginConfig"
        case .getAboutNiudun:
            return "/sys/sysConfig/aboutNiudunToApp"
        case .getAboutApp:
            return "/sys/sysConfig/aboutAppToApp"
        case .initializeVersion:
            return "/sys/softwareVersion/initVersionKey"
        case .getAppConfig:
            return "/sys/sysConfig/getConfigByApp"
        case .getSoftwareUpgradeInfo:
            return "/sys/softwareVersion/upgradeInfo"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getLoginUIConfig:
            return .get
        default :
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .initializePlayerConfig, .getLoginUIConfig, .getAboutNiudun, .getAboutApp, .initializeVersion:
            return .requestPlain
        case .getAppConfig(let typeCode):
            return .requestParameters(parameters: ["typeCode": typeCode], encoding: JSONEncoding.default)
        case .getSoftwareUpgradeInfo(let versionKey):
            return .requestParameters(parameters: ["versionKey": versionKey], encoding: JSONEncoding.default)
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

struct PlayerConfigResponse: Codable {
    let forceRealName: Bool
    let forceBindPhone: Bool
    let allowedUnbindDevice: Bool
    let allowedVideoCapture: Bool
    let configRealStatus: Bool
    let configBindPhone: Bool
}

struct LoginUIConfigResponse: Codable {
    let liji_register: String
    let login_logo: String
    let copyright_company_cn: String
    let personal_protocol_url: String
    let service_protocol_url: String
    let protocol_text: String
    let player_name: String
    let copyright_company: String
}

struct AboutNiudunResponse: Codable {
    let office_url: String?
    let office_image: String?
    let software_name: String?
    let branch_icon: String?
    let company_introduct: String?
}

struct AboutAppResponse: Codable {
    let tips2_txt: String
    let branch_icon: String
    let tips3_value: String
    let tips2_value: String
    let text1: String
    let text2: String
    let tips1_value: String
    let software_version: String
    let software_name: String
    let tips3_txt: String
    let copyright_en: String
    let btn_text: String
    let copyright_cn: String
    let tips1_txt: String
    let btn_value: String
}

struct VersionInitResponse: Codable {
    let downUrl: String
    let forcedUpdating: Bool
    let id: Int
    let idCode: String
    let installPackgeName: String
    let kernel: Bool
    let kernelId: Int
    let merchantId: Int
    let platformType: String
    let releaseTime: String
    let remark: String
    let returnVersionId: Int
    let softwareFileKey: String
    let softwareMd5: String
    let softwareName: String
    let softwareType: String
    let upgradeVersionId: Int
    let version: Int
    let versionKey: String
    let versionStr: String
    let versionSum: String
    let versionValid: Int
}

struct AppConfigResponse: Codable {
    let helper_url: String
}

struct SoftwareUpgradeInfoResponse: Codable {
    let versionKey: String
}
