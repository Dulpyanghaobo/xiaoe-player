//
//  AppDelegate.swift
//  AntPlayerH
//
//  Created by i564407 on 7/16/24.
//

import UIKit
import CoreData
import Tiercel
import ImSDK_Plus
import AVFoundation

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main

class AppDelegate: UIResponder, UIApplicationDelegate, AVCapturePhotoCaptureDelegate {
    
    var window: UIWindow?

    let deviceManager = DeviceManager()
    
    let appConfigManager = AppConfigManager()
    
    var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let path = Cache.defaultDiskCachePathClosure("Test")
        let cacahe = Cache("VideoPlayer", downloadPath: path)
        let manager = SessionManager("VideoPlayer", configuration: configuration, cache: cacahe, operationQueue: DispatchQueue(label: "com.Tiercel.SessionManager.operationQueue"))
        return manager
    }()
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        if sessionManager.identifier == identifier {
            sessionManager.completionHandler = completionHandler
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        V2TIMManager.sharedInstance()?.removeAdvancedMsgListener(listener: self)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        bindDevice()
        // 初始化IM SDK
        bindIM()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AntPlayerH")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    private func bindDevice() {
//        let deviceInfo = SystemDeviceConfig.getDeviceInfo()
//        
//        deviceManager.bindDevice(deviceInfo: deviceInfo) { result in
//            switch result {
//            case .success(let response):
//                print("Device bound successfully: \(response)")
//            case .failure(let error):
//                print("Failed to bind device: \(error)")
//            }
//        }
    }
    
    private func bindIM() {
        IMManager().initializeIM { result in
            switch result {
            case .success(let response):
                print("Device bound successfully: \(response)")
                V2TIMManager.sharedInstance()?.initSDK(response.data?.appid ?? 1400600351, config: V2TIMSDKConfig())

                // 添加消息监听器
                V2TIMManager.sharedInstance()?.addAdvancedMsgListener(listener: self)
            case .failure(let error):
                print("Failed to bind device: \(error)")
            }
        }
    }
}

extension AppDelegate: V2TIMAdvancedMsgListener {
    func onRecvNewMessage(_ msg: V2TIMMessage) {
        if msg.elemType == .ELEM_TYPE_CUSTOM {
            guard let data = msg.customElem?.data else { return }
            if let instruction = String(data: data, encoding: .utf8) {
                // 处理指令
                handleInstruction(instruction)
            }
        }
    }

    private func handleInstruction(_ instruction: String) {
        switch instruction {
        case "close":
            DispatchQueue.main.async {
                UIApplication.shared.currentKeyWindow?.makeToast("关闭播放器")
            }
        case "rename":
            UIApplication.shared.currentViewController?.navigationController?.pushViewController(IdentityVerificationViewController(), animated: true)
        case "camera":
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    let photoSettings = AVCapturePhotoSettings()
                    photoSettings.flashMode = .off // 关闭闪光灯
                    photoSettings.isAutoStillImageStabilizationEnabled = true // 启用防抖
                    photoSettings.isHighResolutionPhotoEnabled = true // 拍摄高分辨率照片

                    let photoOutput = AVCapturePhotoOutput()
                    photoOutput.capturePhoto(with: photoSettings, delegate: self)
                } else {
                    DispatchQueue.main.async {
                        UIApplication.shared.currentKeyWindow?.makeToast("请打开权限")
                    }
                }
            }
        case "relogin":
            UserDefaults.standard.removeObject(forKey: "userToken")
            UserDefaults.standard.synchronize()
            AuthManager().logout { result in
                let loginVC = LoginViewController()
                UIApplication.shared.currentViewController?.navigationController?.pushViewController(loginVC, animated: true)
            }
            // 强制重新登录
        case "yuyin":
            UIApplication.shared.currentViewController?.navigationController?.pushViewController(SpeechViewController(), animated: true)
        default:
            break
        }
    }
}

