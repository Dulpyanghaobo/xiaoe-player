//
//  AppRouter.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import UIKit

public class AppRouter: Router {
    static let shared = AppRouter()

    private weak var navigationController: UINavigationController?

    private init() {}

    func setNavigationController(_ navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func navigate(to destination: Destination) {
        switch destination {
        case .login:
            let loginVC = LoginViewController()
            navigationController?.pushViewController(loginVC, animated: true)
        case .course(let courseType):
            let courseVC = MainTabBarController()
            navigationController?.pushViewController(courseVC, animated: true)
        case .settings:
            let settingsVC = SettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: true)
        case .profile(userId: let userId):
            let settingsVC = SettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
}
