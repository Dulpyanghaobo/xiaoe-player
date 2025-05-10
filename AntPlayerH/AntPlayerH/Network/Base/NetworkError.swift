//
//  NetworkError.swift
//  task_management_tool
//
//  Created by i564407 on 4/17/24.
//

import Foundation

enum NetworkError: Error {
    case badRequest
    case unauthorized
    case forbidden
    case notFound
    case conflict
    case serverError
    case unableToDecode
    case unknown
    case failed(Error)
    case invalidRequest
    case invalidImage
    case invalidResponse(Int)
    case invalidToken

    case underlying(Error)

    var localizedDescription: String {
        switch self {
        case .badRequest:
            return "Invalid request"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .conflict:
            return "Resource conflict"
        case .serverError:
            return "Internal server error"
        case .unableToDecode:
            return "Unable to decode response"
        case .unknown:
            return "Unknown error"
        case .failed(let error):
            return error.localizedDescription
        case .invalidRequest:
            return "Unable to decode response"
        case .invalidImage:
            return "Unable to decode response"
        case .invalidResponse(_):
            return "Unable to decode response"
        case .underlying(_):
            return "Unable to decode response"
        case .invalidToken:
            return "token invaild"
        }
    }
}
