//
//  CustomNetworkLoggerPlugin.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Moya

class CustomNetworkLoggerPlugin: PluginType {
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            print("Invalid request")
            return
        }

        print("🚀 Sending request:")
        print("URL: \(httpRequest.url?.absoluteString ?? "Unknown URL")")
        print("Method: \(httpRequest.httpMethod ?? "Unknown method")")
        
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            print("Headers: \(headers)")
        }
        
        if let body = httpRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
}
