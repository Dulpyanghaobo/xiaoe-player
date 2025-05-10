//
//  SafariViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit
import SafariServices

class SafariViewController: NSObject {
    private var safariViewController: SFSafariViewController?

    func openURL(_ url: URL, from viewController: UIViewController) {
        // 创建SFSafariViewController实例
        safariViewController = SFSafariViewController(url: url)
        
        // 设置代理（可选）
        safariViewController?.delegate = self
        
        // 显示SFSafariViewController
        viewController.present(safariViewController!, animated: true, completion: nil)
    }
}

// MARK: - SFSafariViewControllerDelegate
extension SafariViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // 当用户关闭Safari视图时，释放引用
        safariViewController = nil
    }
}
