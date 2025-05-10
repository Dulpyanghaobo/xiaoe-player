//
//  UIViewController+Extension.swift
//  AntPlayerH
//
//  Created by i564407 on 8/8/24.
//

import UIKit

extension UIViewController {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return currentViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}
