//
//  SDKService.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Moya

enum SDKService {
    case initializeSDK(accesskey: String?)
    case getSDKErrorMessage(errorCode: Int)
}

extension SDKService: TargetType {
    var baseURL: URL {
        return URL(string: "http://101.35.192.187:8088")!
    }
    
    var path: String {
        switch self {
        case .initializeSDK:
            return "/playsdk/appInitSdk"
        case .getSDKErrorMessage:
            return "/playsdk/getSdkErrorMsg"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var task: Task {
        switch self {
        case .initializeSDK(let accesskey):
            if let accesskey = accesskey {
                return .requestParameters(parameters: ["accesskey": accesskey], encoding: JSONEncoding.default)
            } else {
                return .requestPlain
            }
        case .getSDKErrorMessage(let errorCode):
            return .requestParameters(parameters: ["errorCode": errorCode], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        return Data()
    }
}

struct SDKInitResponse: Codable {
    let domain: String
    let initUri: String
    let accessKey: String
}

