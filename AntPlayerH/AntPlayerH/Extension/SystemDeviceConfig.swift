//
//  SystemDeviceConfig.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit

class SystemDeviceConfig {
    static func getDeviceInfo() -> DeviceInfo {
        let device = UIDevice.current
        let screenSize = UIScreen.main.bounds.size
        
        return DeviceInfo(
            delTime: nil,
            deviceBios: nil,
            deviceBrand: "Apple",
            deviceCpu: getCPUType(), // 这里可以根据实际情况获取
            deviceCpuSn: nil,
            deviceDiskSpace: getDeviceDiskSpace(),
            deviceImei: nil,
            deviceInnerVersion: nil,
            deviceLanguage: Locale.current.languageCode,
            deviceMacAddress: nil, // iOS 不允许获取 MAC 地址
            deviceMemory: getDeviceMemory(),
            deviceMemorySpace: nil,
            deviceModel: device.model,
            deviceModelName: getDeviceModelName(),
            deviceName: device.name,
            deviceServerUuid: nil,
            deviceSim: nil,
            deviceSn: nil,
            deviceStatus: 1,
            deviceSystemInstallTime: nil,
            deviceSystemName: device.systemName,
            deviceSystemVersion: device.systemVersion,
            deviceSystemVersionName: nil,
            deviceUuid: UUID().uuidString,
            id: nil,
            idCode: nil,
            lasterLoginIp: getLastLoginIp(),
            lasterLoginLocation: getLastLoginLocation(),
            lasterLoginTime: getLastLoginTime(),
            locationCountry: Locale.current.regionCode,
            loginIp: getLastLoginIp(),
            loginLocation: getLastLoginLocation(),
            loginTime: getLastLoginTime(),
            merchantId: nil,
            otherInfo: nil,
            remark: nil,
            requireId: nil,
            screenHeight: "\(Int(screenSize.height))",
            screenWidth: "\(Int(screenSize.width))",
            userId: nil
        )
    }
    
    private static func getDeviceDiskSpace() -> String {
        let fileManager = FileManager.default
        if let attributes = try? fileManager.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let freeSize = attributes[.systemFreeSize] as? NSNumber,
           let totalSize = attributes[.systemSize] as? NSNumber {
            return "\(totalSize.int64Value / (1024 * 1024 * 1024))GB"
        }
        return "Unknown"
    }
    
    private static func getDeviceMemory() -> String {
        let memory = ProcessInfo.processInfo.physicalMemory
        return "\(memory / (1024 * 1024 * 1024))GB"
    }
    
    private static func getCPUType() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let model = String(cString: machine)
        
        // 根据设备型号返回 CPU 类型
        switch model {
        case "iPhone13,2":
            return "A14 Bionic"
        // 添加更多设备型号和对应的 CPU 类型
        default:
            return "Unknown"
        }
    }
    
    private static func getDeviceModelName() -> String {
        var size = 0
        sysctlbyname("hw.machine", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: Int(size))
        sysctlbyname("hw.machine", &machine, &size, nil, 0)
        let modelIdentifier = String(cString: machine)
        
        // 根据设备型号标识符返回设备名称
        switch modelIdentifier {
        case "iPhone14,2":
            return "iPhone 13 Pro"
        case "iPhone14,3":
            return "iPhone 13 Pro Max"
        case "iPhone14,4":
            return "iPhone 13 Mini"
        case "iPhone14,5":
            return "iPhone 13"
        // 添加更多设备型号标识符和对应的设备名称
        default:
            return modelIdentifier
        }
    }
    
    static func saveLoginInfo(ip: String, location: String) {
        let loginTime = Date().description
        UserDefaults.standard.set(ip, forKey: "lasterLoginIp")
        UserDefaults.standard.set(location, forKey: "lasterLoginLocation")
        UserDefaults.standard.set(loginTime, forKey: "lasterLoginTime")
    }

    static func getLastLoginIp() -> String? {
        return UserDefaults.standard.string(forKey: "lasterLoginIp")
    }

    static func getLastLoginLocation() -> String? {
        return UserDefaults.standard.string(forKey: "lasterLoginLocation")
    }

    static func getLastLoginTime() -> String? {
        return UserDefaults.standard.string(forKey: "lasterLoginTime")
    }
}
