//
//  TokenManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import Foundation

class TokenManager {
    static let shared = TokenManager()
    
    private let tokenKey = "userToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
    
    func isTokenValid() -> Bool {
        // 这里可以添加更多的逻辑来验证 token 是否有效，例如检查 token 是否过期
        return token != nil
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}
