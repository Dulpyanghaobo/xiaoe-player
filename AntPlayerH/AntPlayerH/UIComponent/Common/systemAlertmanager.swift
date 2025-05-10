//
//  systemAlertmanager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit

class SystemAlertManager {
    static func showAlert(on viewController: UIViewController, title: String, message: String, buttonTitle: String = "知道了") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alertController.addAction(confirmAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
