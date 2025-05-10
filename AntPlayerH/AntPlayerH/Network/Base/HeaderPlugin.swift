//
//  HeaderPlugin.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//

import Moya
import Foundation
import CommonCrypto

struct HeaderPlugin: PluginType {
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        let ts = "\(Int(Date().timeIntervalSince1970 * 1000))"
        let ct = "dp1WFd8QBjV3kqIE" // IOS默认值
        let st = "cZYq5KgX41O3o0ZK" // 软件类型默认值
        let rs = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        let ri = md5("\(ts)\(rs)\(ct)\(st)\(rs)")
        let vk = "cYtx4zGL96s1P8xNYXZ8xefRMhd5aKjA"
        
        request.addValue(ts, forHTTPHeaderField: "ts")
        request.addValue(ct, forHTTPHeaderField: "ct")
        request.addValue(st, forHTTPHeaderField: "st")
        request.addValue(rs, forHTTPHeaderField: "rs")
        request.addValue(ri, forHTTPHeaderField: "ri")
        request.addValue(vk, forHTTPHeaderField: "vk")

        // 如果需要token，可以从某个地方获取，比如用户登录信息
        if let token = UserDefaults.standard.string(forKey: "userToken") {
            request.addValue(token, forHTTPHeaderField: "tk")
        }
        
        return request
    }
    
    private func md5(_ string: String) -> String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)
        
        _ = digestData.withUnsafeMutableBytes { digestBytes in
            messageData.withUnsafeBytes { messageBytes in
                CC_MD5(messageBytes, CC_LONG(messageData.count), digestBytes)
            }
        }
        return digestData.map { String(format: "%02hhx", $0) }.joined()
    }
}
