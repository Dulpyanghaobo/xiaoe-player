//
//  UIView+Extension.swift
//  AntPlayerH
//
//  Created by i564407 on 8/3/24.
//

import UIKit

extension UIView {
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
        var parentViewController: UIViewController? {
            var responder: UIResponder? = self
            while responder != nil {
                responder = responder?.next
                if let viewController = responder as? UIViewController {
                    return viewController
                }
            }
            return nil
        }
}
