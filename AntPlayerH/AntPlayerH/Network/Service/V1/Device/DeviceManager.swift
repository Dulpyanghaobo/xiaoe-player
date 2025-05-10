//
//  DeviceManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

// MARK: - DeviceManager

class DeviceManager {
    let networkManager: NetworkManager<DeviceService>
    
    init() {
        networkManager = NetworkManager<DeviceService>()
    }
    
    func bindDevice(deviceInfo: DeviceInfo, completion: @escaping (Result<ApiResponse<BindDeviceResponse>, Error>) -> Void) {
        networkManager.request(target: .bindDevice(deviceInfo: deviceInfo)) { (result: Result<ApiResponse<BindDeviceResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func deleteDevice(deviceInfo: DeviceInfo, completion: @escaping (Result<ApiResponse<DeleteDeviceResponse>, Error>) -> Void) {
        networkManager.request(target: .deleteDevice(deviceInfo: deviceInfo)) { (result: Result<ApiResponse<DeleteDeviceResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
    
    func getDeviceList(completion: @escaping (Result<ApiResponse<DeviceListResponse>, Error>) -> Void) {
        networkManager.request(target: .getDeviceList) { (result: Result<ApiResponse<DeviceListResponse>, NetworkError>) in
            completion(result.mapError { $0 as Error })
        }
    }
}
/**在app启动的时候调用
 /biz/deviceInfo/bindDevice绑定设备，
 
 let deviceManager = DeviceManager()

 // 绑定设备
 let deviceInfo = DeviceInfo(deviceUuid: "123456", deviceName: "iPhone 12", /* other properties */)
 deviceManager.bindDevice(deviceInfo: deviceInfo) { result in
     switch result {
     case .success(let response):
         print("Device bound successfully: \(response.data)")
     case .failure(let error):
         print("Failed to bind device: \(error)")
     }
 }

 // 删除设备
 deviceManager.deleteDevice(deviceInfo: deviceInfo) { result in
     switch result {
     case .success(let response):
         print("Device deleted successfully: \(response.data)")
     case .failure(let error):
         print("Failed to delete device: \(error)")
     }
 }

 // 获取设备列表
 deviceManager.getDeviceList { result in
     switch result {
     case .success(let response):
         print("Device list: \(response.data.devices)")
     case .failure(let error):
         print("Failed to get device list: \(error)")
     }
 }
 **/
