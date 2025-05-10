//
//  DeviceService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

enum DeviceService {
    case bindDevice(deviceInfo: DeviceInfo)
    case deleteDevice(deviceInfo: DeviceInfo)
    case getDeviceList
}

extension DeviceService: TargetType {
    var baseURL: URL {
        return APIEnvironment.baseURL(for: .v1)
    }
    
    var path: String {
        switch self {
        case .bindDevice:
            return "/biz/deviceInfo/bindDevice"
        case .deleteDevice:
            return "/biz/deviceInfo/delDeviceByStuden"
        case .getDeviceList:
            return "/biz/deviceInfo/queryDevicesByStudent"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .bindDevice(let deviceInfo), .deleteDevice(let deviceInfo):
            return .requestJSONEncodable(deviceInfo)
        case .getDeviceList:
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

// MARK: - Models

struct DeviceInfo: Codable {
    let delTime: String?
    let deviceBios: String?
    let deviceBrand: String?
    let deviceCpu: String?
    let deviceCpuSn: String?
    let deviceDiskSpace: String?
    let deviceImei: String?
    let deviceInnerVersion: String?
    let deviceLanguage: String?
    let deviceMacAddress: String?
    let deviceMemory: String?
    let deviceMemorySpace: String?
    let deviceModel: String?
    let deviceModelName: String?
    let deviceName: String?
    let deviceServerUuid: String?
    let deviceSim: String?
    let deviceSn: String?
    let deviceStatus: Int?
    let deviceSystemInstallTime: String?
    let deviceSystemName: String?
    let deviceSystemVersion: String?
    let deviceSystemVersionName: String?
    let deviceUuid: String?
    let id: Int?
    let idCode: String?
    let lasterLoginIp: String?
    let lasterLoginLocation: String?
    let lasterLoginTime: String?
    let locationCountry: String?
    let loginIp: String?
    let loginLocation: String?
    let loginTime: String?
    let merchantId: Int?
    let otherInfo: String?
    let remark: String?
    let requireId: Int?
    let screenHeight: String?
    let screenWidth: String?
    let userId: Int?
}

// MARK: - Response Models

struct BindDeviceResponse: Codable {
    // Define properties based on the actual response
}

struct DeleteDeviceResponse: Codable {
    // Define properties based on the actual response
}

struct DeviceListResponse: Codable {
    let devices: [DeviceInfo]
}

