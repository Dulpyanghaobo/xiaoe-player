//
//  LoginManager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit

class LoginManager {
    
    static let shared = LoginManager()
    
    let authManager = AuthManager()

    
    private init() {}
    
    func performLogout(from navigationController: UINavigationController?) {
        // Remove user token
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.synchronize()
        
        // Perform logout action with your auth manager
        authManager.logout { result in
            // Check the result and navigate to the login screen
            DispatchQueue.main.async {
                let loginVC = LoginViewController()
                navigationController?.setViewControllers([loginVC], animated: true)
            }
        }
    }
}
