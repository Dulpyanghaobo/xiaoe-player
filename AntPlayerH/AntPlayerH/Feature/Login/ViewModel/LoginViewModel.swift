//
//  LoginViewModel.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation

class LoginViewModel {
    // MARK: - Properties
    var phoneNumber: String = ""
    var smsCode: String = ""
    var username: String = ""
    var password: String = ""
    var isAgreementAccepted: Bool = false
    var loginUIConfig: LoginUIConfigResponse?
    var captchaKey: String?
    
    // MARK: - Outputs (for UI updates)
    var showError: ((String) -> Void)?
    var showSuccess: ((String) -> Void)?
    var showWarning: ((String) -> Void)?
    var jumpToHome: (() -> Void)?
    var configLoaded: ((LoginUIConfigResponse?) -> Void)?

    private let authManager = AuthManager()

    func loadLoginUIConfig() {
        AppConfigManager().getLoginUIConfig { [weak self] result in
            switch result {
            case .success(let response):
                self?.loginUIConfig = response.data ?? LoginUIConfigResponse.init(liji_register: "https://jnplayer.com", login_logo: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-1.lanrentuku.com%2F2020%2F11%2F6%2F9232f107-4dac-4006-9c7e-e825df5e52e1.png%3FimageView2%2F2%2Fw%2F500&refer=http%3A%2F%2Fi-1.lanrentuku.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1652857038&t=83ba6c42edec38afee64d52777ed7d02", copyright_company_cn: "湖南省锐翊信息科技有限责任公司 版权所有", personal_protocol_url: "https://beian.miit.gov.cn/#/Integrated/lawStatute", service_protocol_url: "https://beian.miit.gov.cn/#/Integrated/lawStatute", protocol_text: "进入牛盾播放器即代表您同意《牛盾播播放服务协议》与《个人信息保护政策》", player_name: "牛盾播放器", copyright_company: "Hunan Ruiyi Information Technology Co., LTD")
                self?.configLoaded?(self?.loginUIConfig)
            case .failure(let error):
                self?.loginUIConfig = LoginUIConfigResponse.init(liji_register: "https://jnplayer.com", login_logo: "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fi-1.lanrentuku.com%2F2020%2F11%2F6%2F9232f107-4dac-4006-9c7e-e825df5e52e1.png%3FimageView2%2F2%2Fw%2F500&refer=http%3A%2F%2Fi-1.lanrentuku.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=auto?sec=1652857038&t=83ba6c42edec38afee64d52777ed7d02", copyright_company_cn: "湖南省锐翊信息科技有限责任公司 版权所有", personal_protocol_url: "https://beian.miit.gov.cn/#/Integrated/lawStatute", service_protocol_url: "https://beian.miit.gov.cn/#/Integrated/lawStatute", protocol_text: "进入牛盾播放器即代表您同意《牛盾播播放服务协议》与《个人信息保护政策》", player_name: "牛盾播放器", copyright_company: "Hunan Ruiyi Information Technology Co., LTD")
                self?.configLoaded?(self?.loginUIConfig)
                self?.showError?("加载登录配置失败: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Methods
    func sendSmsCode(completion: @escaping (Bool) -> Void) {
        guard !phoneNumber.isEmpty else {
            showError?("请输入手机号")
            return
        }
        
        authManager.loginPhoneSms(phone: phoneNumber) { [weak self] result in
            switch result {
            case .success(let response):
                self?.showSuccess?("发送验证码成功")
                completion(true)
                self?.captchaKey = response.data
            case .failure(let error):
                completion(false)
                self?.showError?("发送验证码失败: \(error.localizedDescription)")
            }
        }
    }
    
    func login(loginType: LoginType) {
        if loginType == .phoneLogin {
            loginWithPhoneAndSms()
        } else {
            loginWithUsernameAndPassword()
        }
    }
    
    private func loginWithPhoneAndSms() {
        guard let captchaKey = captchaKey, !phoneNumber.isEmpty, !smsCode.isEmpty else {
            showError?("请填写完整信息")
            return
        }
        
        authManager.loginPhone(captchaKey: captchaKey, username: phoneNumber, captcha: smsCode) { [weak self] result in
            switch result {
            case .success(let response):
                guard let loginResponse = response.data else { return  }
                UserManager.shared.saveLoginResponse(loginResponse)
                // 获取IP地址和地理位置
                IpManager.getIPAddress { ipResult in
                    switch ipResult {
                    case .success(let ip):
                        IpManager.getLocation(ip: ip) { locationResult in
                            switch locationResult {
                            case .success(let location):
                                let dispatchGroup = DispatchGroup()

                                // 第一个任务：保存登录信息并绑定设备
                                dispatchGroup.enter()
                                DispatchQueue.global(qos: .userInitiated).async {
                                    SystemDeviceConfig.saveLoginInfo(ip: ip, location: location)
                                    let deviceInfo = SystemDeviceConfig.getDeviceInfo()
                                    
                                    DeviceManager().bindDevice(deviceInfo: deviceInfo) { result in
                                        switch result {
                                        case .success(let response):
                                            print("Device bound successfully: \(response)")
                                        case .failure(let error):
                                            print("Failed to bind device: \(error)")
                                        }
                                        dispatchGroup.leave()
                                    }
                                }

                                // 第二个任务：初始化播放器配置
                                dispatchGroup.enter()
                                DispatchQueue.global(qos: .userInitiated).async {
                                    AppConfigManager().initializePlayerConfig { result in
                                        switch result {
                                        case .success(let response):
                                            if let configData = response.data {
                                                do {
                                                    // 编码并保存播放器配置
                                                    let encoder = JSONEncoder()
                                                    let encodedData = try encoder.encode(configData)
                                                    UserDefaults.standard.set(encodedData, forKey: "PlayerConfig")
                                                } catch {
                                                    print("Failed to encode PlayerConfigResponse: \(error)")
                                                }
                                            }
                                        case .failure(let error):
                                            print("Failed to initialize player config: \(error)")
                                        }
                                        dispatchGroup.leave()
                                    }
                                }

                                dispatchGroup.enter()
                                DispatchQueue.global(qos: .userInitiated).async {
                                    self?.authManager.getUserSig { result in
                                        switch result {
                                        case .success(let response):
                                            print("Failed to initialize player config: \(response)")
                                        case .failure(let error):
                                            print("Failed to initialize player config: \(error)")
                                        }
                                        dispatchGroup.leave()
                                    }
                                }
                                
                                

                                // 等待所有任务完成
                                dispatchGroup.notify(queue: DispatchQueue.main) {
                                    print("All tasks completed")
                                    // 如果需要，可以在这里执行其他任务，比如更新 UI 或通知用户
                                }
                            case .failure(let error):
                                print("Failed to get location: \(error)")
                            }
                        }
                    case .failure(let error):
                        print("Failed to get IP address: \(error)")
                    }
                }
                self?.jumpToHome?()
            case .failure(let error):
                self?.showError?("登录失败: \(error.localizedDescription)")
            }
        }
    }
    
    private func loginWithUsernameAndPassword() {
        guard !username.isEmpty, !password.isEmpty else {
            showError?("请填写完整信息")
            return
        }
        
        authManager.login(username: username, password: password) { [weak self] result in
            switch result {
            case .success(let response):
                guard let loginResponse = response.data else { return  }
                UserManager.shared.saveLoginResponse(loginResponse)
                self?.jumpToHome?()
            case .failure(let error):
                self?.showError?("登录失败: \(error.localizedDescription)")
            }
        }
    }
}
