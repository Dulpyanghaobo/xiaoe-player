//
//  NetworkManager.swift
//  task_management_tool
//
//  Created by i564407 on 4/17/24.
//

import Foundation
import Moya
import SwiftyJSON

@available(iOS 16.0, *)
protocol Networkable {
    associatedtype Target: TargetType
    var provider: MoyaProvider<Target> { get }
    func request<T: Decodable>(target: Target, completion: @escaping (Result<T, NetworkError>) -> Void)
    func requestAsync<T: Decodable>(target: Target) async throws -> T

}
@available(iOS 16.0, *)
class NetworkManager<Target: TargetType>: Networkable {

    internal let provider: MoyaProvider<Target>
    
    init() {
        let cache = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024, diskPath: "myCache")
        let cachePlugin = CachePolicyPlugin(cache: cache)
        provider = MoyaProvider<Target>(plugins:[HeaderPlugin(), CustomNetworkLoggerPlugin(), cachePlugin, MockDataPlugin()])
    }
    
    func request<T: Decodable>(target: Target, completion: @escaping (Result<T, NetworkError>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let statusCode = response.statusCode
                    if statusCode >= 200 && statusCode <= 299 {
                        let json = try JSON(data: response.data)
                        if let code = json["status"].int {
                            // Handle specific error codes
                            if code == 10100003 {
                                self.handleError(.invalidToken)
                                completion(.failure(.invalidToken))
                                return
                            }
                        }
                        let data = try json.rawData()
                        let results = try JSONDecoder().decode(T.self, from: data)
                        print("Request successful: \(results)")
                        completion(.success(results))
                    } else {
                        self.handleError(.badRequest)
                        completion(.failure(.invalidResponse(statusCode)))
                    }
                } catch {
                    print("Request successful: \(response)")

                    self.handleError(.unableToDecode) // Handle the error before completion
                    completion(.failure(.unableToDecode))
                    print("解码失败: \(error.localizedDescription)")

                }
            case let .failure(moyaError):
                let error = self.parseError(moyaError: moyaError)
                self.handleError(error) // Handle the error before completion
                completion(.failure(error))
                print("解码失败: \(error.localizedDescription)")

            }
        }
    }

    func requestAsync<T: Decodable>(target: Target) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case let .success(response):
                    do {
                        let statusCode = response.statusCode
                        if statusCode >= 200 && statusCode <= 299 {
                            let results = try JSONDecoder().decode(T.self, from: response.data)
                            continuation.resume(returning: results)
                        } else {
                            continuation.resume(throwing: NetworkError.invalidResponse(statusCode))
                        }
                    } catch {
                        continuation.resume(throwing: NetworkError.unableToDecode)
                    }
                case let .failure(moyaError):
                    let error = self.parseError(moyaError: moyaError)
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func parseError(moyaError: MoyaError) -> NetworkError {
        if let response = moyaError.response {
            let statusCode = response.statusCode
            let error = self.parseErrorFromResponse(response)
            
            switch statusCode {
            case 400:
                return .badRequest
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 409:
                return .conflict
            case 500...599:
                return .serverError
            default:
                return error ?? .unknown
            }
        } else {
            return .failed(moyaError)
        }
    }
    
    private func parseErrorFromResponse(_ response: Response) -> NetworkError? {
        guard let data = try? response.mapJSON() as? [String: Any],
              let message = data["message"] as? String else {
            return nil
        }
        return NetworkError.failed(NSError(domain: "NetworkError", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey: message]))
    }
    
    private func showPopup(message: String) {
//        let button = UIButton(type: .custom)
//        button.setTitle("确定", for: .normal)
//        let popView = DefaultView(title: "错误", message: message, buttonTitles: ["去登录":{
//            UserDefaults.standard.removeObject(forKey: "userToken")
//            UserDefaults.standard.synchronize()
//            let loginVC = LoginViewController()
//            UIViewController.currentViewController()?.navigationController?.pushViewController(loginVC, animated: true)
//        }])
//        PopupManager.shared.showPopup(PopupView(contentView: popView, popupType: .center, animationType: .fade))
    }
    
    private func handleError(_ error: NetworkError) {
        switch error {
        case .invalidToken:
            showPopup(message: error.localizedDescription)
        case .unauthorized:
            showPopup(message: "Unauthorized access. Please log in again.")
        case .forbidden:
            showPopup(message: "Access forbidden. You do not have permission.")
        case .notFound:
            showPopup(message: "Requested resource not found.")
        case .serverError:
            showPopup(message: "Internal server error. Please try again later.")
        case .badRequest:
            showPopup(message: "Bad request. Please check your input.")
        default:
            showPopup(message: "An unknown error occurred. Please try again.")
        }
    }
}
