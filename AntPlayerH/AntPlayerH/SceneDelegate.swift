//
//  SceneDelegate.swift
//  AntPlayerH
//
//  Created by i564407 on 7/16/24.
//

import UIKit
import ScreenshotPreventing
@available(iOS 16.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidConnect), name: UIScreen.didConnectNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidDisconnect), name: UIScreen.didDisconnectNotification, object: nil)
        let navigationController = UINavigationController()

        AppRouter.shared.setNavigationController(navigationController)
        // 检查是否是首次启动
        if UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            let launchViewController = LaunchViewController.init(launchType: .notFirstTime)
            navigationController.setViewControllers([launchViewController], animated: false)

            window?.rootViewController = navigationController
        } else {
            // 首次启动，显示 LaunchViewController
            let launchViewController = LaunchViewController.init(launchType: .firstTime)
            navigationController.setViewControllers([launchViewController], animated: false)
            window?.rootViewController = navigationController
            // 标记已经启动过
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        window?.makeKeyAndVisible()
    }
    func sceneDidDisconnect(_ scene: UIScene) {

    }


    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    @objc func screenDidConnect(notification: Notification) {
        if let screen = notification.object as? UIScreen, screen.mirrored != nil {
            // 检测到外部显示器连接，可以在这里采取行动
            // 例如，显示一个警告或隐藏敏感内容
            print("检测到外部显示器连接")
        }
    }
    
    @objc func screenDidDisconnect(notification: Notification) {
        // 外部显示器断开连接
        print("外部显示器断开连接")
    }
}
