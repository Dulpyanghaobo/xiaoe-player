//
//  UserManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/22/24.
//

import Foundation

class UserManager {
    static let shared = UserManager()
    
    private let userDefaults = UserDefaults.standard
    private let loginResponseKey = "LoginResponse"
    
    private init() {}
    
    // 保存 LoginResponse 到 UserDefaults
    func saveLoginResponse(_ response: LoginResponse) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(response) {
            userDefaults.set(encoded, forKey: loginResponseKey)
        }
    }
    
    // 从 UserDefaults 加载 LoginResponse
    func loadLoginResponse() -> LoginResponse? {
        if let savedData = userDefaults.data(forKey: loginResponseKey) {
            let decoder = JSONDecoder()
            if let loadedResponse = try? decoder.decode(LoginResponse.self, from: savedData) {
                return loadedResponse
            }
        }
        return nil
    }
    
    // 清除用户数据
    func clearUserData() {
        userDefaults.removeObject(forKey: loginResponseKey)
    }
}
