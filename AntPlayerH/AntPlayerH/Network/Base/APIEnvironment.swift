//
//  APIEnvironment.swift
//  task_management_tool
//
//  Created by i564407 on 4/17/24.
//

import Foundation

enum APIVersion {
    case v1
}

struct APIEnvironment {
    static let currentVersion: APIVersion = .v1
    static func baseURL(for version: APIVersion) -> URL {
        switch version {
        case .v1:
            guard  let url = URL(string: "http://localhost:8081") else {
                fatalError("APIBaseURL is not set in plist for this environment")
            }
            return url
        }
    }
}



