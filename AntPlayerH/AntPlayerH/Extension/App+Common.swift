//
//  App+Common.swift
//  task_management_tool
//
//  Created by i564407 on 4/18/24.
//

import Foundation
import UIKit

// 获取状态栏高度
var statusBarHeight: CGFloat {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
}

// 获取屏幕宽度
var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

// 获取屏幕高度
var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


// 获取导航栏高度
var navigationBarHeight: CGFloat {
    return UINavigationController().navigationBar.frame.size.height
}

// 获取状态栏+导航栏的高度
var navigationFullHeight: CGFloat {
    return statusBarHeight + navigationBarHeight
}


// 获取底部导航栏高度
var tabBarHeight: CGFloat {
    return UITabBarController().tabBar.frame.size.height
}

// 获取底部导航栏高度（包括安全区）
var tabBarFullHeight: CGFloat {
    let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    let bottomSafeArea = window?.safeAreaInsets.bottom ?? 0
    return tabBarHeight + bottomSafeArea
}

// 获取设备类型
var deviceType: String {
    return UIDevice.current.model
}

//// 检查是否连接到WiFi
//var isConnectedToWiFi: Bool {
//    let reachability = try? Reachability()
//    return reachability?.connection == .wifi
//}

// 获取iOS版本
var iOSVersion: String {
    return UIDevice.current.systemVersion
}

// 获取设备名称
var deviceName: String {
    return UIDevice.current.name
}

// 获取设备系统名称
var systemName: String {
    return UIDevice.current.systemName
}

// 获取设备电池电量
var batteryLevel: Float {
    return UIDevice.current.batteryLevel
}

// 获取设备电池状态
var batteryState: UIDevice.BatteryState {
    return UIDevice.current.batteryState
}

// 获取设备UUID
var deviceUUID: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? ""
}

// 获取设备可用存储空间
var availableStorage: Int64 {
    let fileURL = URL(fileURLWithPath: NSHomeDirectory() as String)
    if let values = try? fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
       let capacity = values.volumeAvailableCapacityForImportantUsage {
        return capacity
    } else {
        return 0
    }
}

// 检查是否启用了通知
//var isNotificationEnabled: Bool {
//    let currentSettings = UNUserNotificationCenter.current().getNotificationSettings { settings in
//        return settings.authorizationStatus == .authorized
//    }
//    return currentSettings
//}

// 获取当前语言
var currentLanguage: String {
    return Locale.preferredLanguages.first ?? "Unknown"
}

// 获取当前时区
var currentTimeZone: String {
    return TimeZone.current.identifier
}

// 获取设备屏幕亮度
var screenBrightness: CGFloat {
    return UIScreen.main.brightness
}

//// 获取设备音量
//var deviceVolume: Float {
//    let audioSession = AVAudioSession.sharedInstance()
//    return audioSession.outputVolume
//}

// 检查是否启用了飞行模式
var isAirplaneModeEnabled: Bool {
    let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView
    let foregroundView = statusBar?.value(forKey: "foregroundView") as? UIView
    let airplaneMode = foregroundView?.subviews.first(where: { $0.isKind(of: NSClassFromString("UIStatusBarAirplaneModeItemView")!) })
    return airplaneMode != nil
}

// 获取设备屏幕分辨率
var screenResolution: CGSize {
    let scale = UIScreen.main.scale
    let bounds = UIScreen.main.bounds
    return CGSize(width: bounds.width * scale, height: bounds.height * scale)
}
