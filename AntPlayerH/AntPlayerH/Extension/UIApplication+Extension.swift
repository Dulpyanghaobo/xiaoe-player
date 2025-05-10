//
//  UIApplication+Extension.swift
//  AntPlayerH
//
//  Created by i564407 on 8/11/24.
//

import Foundation
import UIKit
extension UIApplication {
    var currentViewController: UIViewController? {
        guard let rootViewController = keyWindow?.rootViewController else {
            return nil
        }
        return getVisibleViewController(from: rootViewController)
    }

    private func getVisibleViewController(from vc: UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController {
            return getVisibleViewController(from: navigationController.visibleViewController!)
        }
        
        if let tabBarController = vc as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return getVisibleViewController(from: selected)
            }
        }
        
        if let presented = vc.presentedViewController {
            return getVisibleViewController(from: presented)
        }
        
        return vc
    }
}

extension UIApplication {
    var currentKeyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return windows.filter { $0.isKeyWindow }.first
        }
    }
}
