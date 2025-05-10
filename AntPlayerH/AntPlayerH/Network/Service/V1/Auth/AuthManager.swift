//
//  AuthManager.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//

import Foundation

class AuthManager {
    let networkManager: NetworkManager<AuthService>
    
    init() {
        networkManager = NetworkManager<AuthService>()
    }
    
    func login(username: String, password: String, completion: @escaping (Result<ApiResponse<LoginResponse>, Error>) -> Void) {
        getPwdKey(userName: username) { result in
            switch result {
            case .success(let response):
                guard let pwdKeyData = response.data else {
                    completion(.failure(NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get password key data"])))
                    return
                }
                guard let encryptedPassword = password.aesEncrypt(key: pwdKeyData.ik, iv: pwdKeyData.iv) else {
                    completion(.failure(NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to encrypt password"])))
                    return
                }
                self.networkManager.request(target: .login(username: username, password: encryptedPassword, loginKey: "\(pwdKeyData.ik)\(username)\(pwdKeyData.iv)".MD5)) { (result: Result<ApiResponse<LoginResponse>, NetworkError>) in
                    switch result {
                    case .success(let loginResponse):
                        UserDefaults.standard.setValue(loginResponse.data?.token, forKey: "userToken")
                        completion(.success(loginResponse))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPwdKey(userName: String, completion: @escaping (Result<ApiResponse<GetPwdKeyResponse>, Error>) -> Void) {
        networkManager.request(target: .getPwdKey(userName: userName)) { (result: Result<ApiResponse<GetPwdKeyResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginPhoneSms(phone: String, completion: @escaping (Result<ApiResponse<String>, Error>) -> Void) {
        networkManager.request(target: .loginPhoneSms(phone: phone)) { (result: Result<ApiResponse<String>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loginPhone(captchaKey: String, username: String, captcha: String, completion: @escaping (Result<ApiResponse<LoginResponse>, Error>) -> Void) {
        networkManager.request(target: .loginPhone(captchaKey: captchaKey, username: username, captcha: captcha)) { (result: Result<ApiResponse<LoginResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                UserDefaults.standard.setValue(response.data?.token, forKey: "userToken")
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func logout(completion: @escaping (Result<ApiResponse<EmptyData>, Error>) -> Void) {
        networkManager.request(target: .logout) { (result: Result<ApiResponse<EmptyData>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func bindPhoneSmsCode(phone: String, completion: @escaping (Result<ApiResponse<SmsCodeResponse>, Error>) -> Void) {
        networkManager.request(target: .bindPhoneSmsCode(phone: phone)) { (result: Result<ApiResponse<SmsCodeResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func bindPhone(captcha: String, captchaKey: String, phone: String, completion: @escaping (Result<ApiResponse<EmptyData>, Error>) -> Void) {
        networkManager.request(target: .bindPhone(captcha: captcha, captchaKey: captchaKey, phone: phone)) { (result: Result<ApiResponse<EmptyData>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getUserSig(completion: @escaping (Result<ApiResponse<String>, Error>) -> Void) {
        networkManager.request(target: .getUserSig) { (result: Result<ApiResponse<String>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // 新增方法
    
    func getRealStatus(completion: @escaping (Result<ApiResponse<RealStatusResponse>, Error>) -> Void) {
        networkManager.request(target: .getRealStatus) { (result: Result<ApiResponse<RealStatusResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func uploadSfz(type: Int, file: Data, completion: @escaping (Result<ApiResponse<UploadSfzResponse>, Error>) -> Void) {
        networkManager.request(target: .uploadSfz(type: type, file: file)) { (result: Result<ApiResponse<UploadSfzResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkFaceStatusByTx(completion: @escaping (Result<ApiResponse<CheckFaceStatusResponse>, Error>) -> Void) {
        networkManager.request(target: .checkFaceStatusByTx) { (result: Result<ApiResponse<CheckFaceStatusResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func checkFaceCallback(orderNo: String, completion: @escaping (Result<ApiResponse<Bool>, Error>) -> Void) {
        networkManager.request(target: .checkFaceCallback(orderNo: orderNo)) { (result: Result<ApiResponse<Bool>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getFaceSdkSign(bizType: Int, completion: @escaping (Result<ApiResponse<FaceSdkSignResponse>, Error>) -> Void) {
        networkManager.request(target: .getFaceSdkSign(bizType: bizType)) { (result: Result<ApiResponse<FaceSdkSignResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getRealSDKSign(nonce: String, completion: @escaping (Result<ApiResponse<RealSdkSignResponse>, Error>) -> Void) {
        networkManager.request(target: .getRealSDKSign(nonce: nonce)) { (result: Result<ApiResponse<RealSdkSignResponse>, NetworkError>) in
            switch result {
            case .success(let response):
                completion(.success(response))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
struct EmptyData: Codable {}

/**
 let authManager = AuthManager()

 // 用户登出
 authManager.logout { result in
     switch result {
     case .success(let response):
         print("Logout successful: \(response.msg)")
     case .failure(let error):
         print("Logout failed: \(error)")
     }
 }

 // 发送绑定手机验证码
 authManager.bindPhoneSmsCode(phone: "1234567890") { result in
     switch result {
     case .success(let response):
         print("SMS code sent: \(response.data ?? "")")
     case .failure(let error):
         print("Failed to send SMS code: \(error)")
     }
 }

 // 绑定手机
 authManager.bindPhone(captcha: "1234", captchaKey: "key", phone: "1234567890") { result in
     switch result {
     case .success(let response):
         print("Phone bound successfully: \(response.msg)")
     case .failure(let error):
         print("Failed to bind phone: \(error)")
     }
 }

 // 获取用户登录IM的秘钥
 authManager.getUserSig { result in
     switch result {
     case .success(let response):
         print("User Sig: \(response.data ?? "")")
     case .failure(let error):
         print("Failed to get User Sig: \(error)")
     }
 }
 **/
