//
//  AppConfigManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

class AppConfigManager {
    let networkManager: NetworkManager<AppConfigService>
    
    init() {
        networkManager = NetworkManager<AppConfigService>()
    }
    
    func initializePlayerConfig(completion: @escaping (Result<ApiResponse<PlayerConfigResponse>, Error>) -> Void) {
        networkManager.request(target: .initializePlayerConfig) { (result: Result<ApiResponse<PlayerConfigResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getLoginUIConfig(completion: @escaping (Result<ApiResponse<LoginUIConfigResponse>, Error>) -> Void) {
        networkManager.request(target: .getLoginUIConfig) { (result: Result<ApiResponse<LoginUIConfigResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getAboutNiudun(completion: @escaping (Result<ApiResponse<AboutNiudunResponse>, Error>) -> Void) {
        networkManager.request(target: .getAboutNiudun) { (result: Result<ApiResponse<AboutNiudunResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getAboutApp(completion: @escaping (Result<ApiResponse<AboutAppResponse>, Error>) -> Void) {
        networkManager.request(target: .getAboutApp) { (result: Result<ApiResponse<AboutAppResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func initializeVersion(completion: @escaping (Result<ApiResponse<VersionInitResponse>, Error>) -> Void) {
        networkManager.request(target: .initializeVersion) { (result: Result<ApiResponse<VersionInitResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getAppConfig(typeCode: String, completion: @escaping (Result<ApiResponse<AppConfigResponse>, Error>) -> Void) {
        networkManager.request(target: .getAppConfig(typeCode: typeCode)) { (result: Result<ApiResponse<AppConfigResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getSoftwareUpgradeInfo(versionKey: String, completion: @escaping (Result<ApiResponse<SoftwareUpgradeInfoResponse>, Error>) -> Void) {
        networkManager.request(target: .getSoftwareUpgradeInfo(versionKey: versionKey)) { (result: Result<ApiResponse<SoftwareUpgradeInfoResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}

/**
 let appConfigManager = AppConfigManager()

 // 初始化播放器配置
 appConfigManager.initializePlayerConfig { result in
     switch result {
     case .success(let response):
         print("Player config: \(response.data)")
     case .failure(let error):
         print("Failed to initialize player config: \(error)")
     }
 }

 // 获取登录界面的配置文案
 appConfigManager.getLoginUIConfig { result in
     switch result {
     case .success(let response):
         print("Login UI config: \(response.data)")
     case .failure(let error):
         print("Failed to get login UI config: \(error)")
     }
 }

 // 获取关于牛盾的信息
 appConfigManager.getAboutNiudun { result in
     switch result {
     case .success(let response):
         print("About Niudun: \(response.data)")
     case .failure(let error):
         print("Failed to get about Niudun: \(error)")
     }
 }

 // 获取关于应用的信息
 appConfigManager.getAboutApp { result in
     switch result {
     case .success(let response):
         print("About App: \(response.data)")
     case .failure(let error):
         print("Failed to get about App: \(error)")
     }
 }

 // 初始化版本信息
 appConfigManager.initializeVersion { result in
     switch result {
     case .success(let response):
         print("Version init: \(response.data)")
     case .failure(let error):
         print("Failed to initialize version: \(error)")
     }
 }

 // 获取APP的配置信息
 appConfigManager.getAppConfig(typeCode: "app_help_center") { result in
     switch result {
     case .success(let response):
         print("App config: \(response.data)")
     case .failure(let error):
         print("Failed to get app config: \(error)")
     }
 }

 // 获取软件升级信息
 appConfigManager.getSoftwareUpgradeInfo(versionKey: "v1.0.0") { result in
     switch result {
     case .success(let response):
         print("Software upgrade info: \(response.data)")
     case .failure(let error):
         print("Failed to get software upgrade info: \(error)")
     }
 }
 
 */
