//
//  WBFaceViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit
import SnapKit
//import TencentCloudHuiyanSDKFace
//
//class WBFaceViewController: BaseViewController, WBFaceVerifyCustomerServiceDelegate {
//    func wbfaceVerifyCustomerServiceDidFinished(with faceVerifyResult: WBFaceVerifyResult) {
//        
//    }
//    func wbfaceVerifyCustomerServiceWillUploadBestImage(_ bestImage: UIImage) {
//        
//    }
//        
//    var faceSdkSignResponse: FaceSdkSignResponse?
//    
//    init(faceSdkSignResponse: FaceSdkSignResponse? = nil) {
//        self.faceSdkSignResponse = faceSdkSignResponse
//        super.init()
//        startService()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//
//    @objc private func thirdButtonServiceClicked(_ button: UIButton) {
//        startService()
//    }
//    
//    private func getSDKSettings() -> WBFaceVerifySDKConfig {
//        let config = WBFaceVerifySDKConfig()
//        config.recordVideo = true
//        config.checkWillVideo = true;
//        config.recordWillVideo = true;
//        config.theme = .lightness
//        config.language = .EN
//        config.enableTrackLog = 1
//        // Set other configuration parameters as needed
//        return config
//    }
//    
//    private func startService() {
//        guard let model = faceSdkSignResponse else { return }
//        WBFaceVerifyCustomerService.sharedInstance().delegate = self
//        WBFaceVerifyCustomerService.sharedInstance().initSDK(withUserId: model.openApiUserId, nonce: model.openApiNonce, sign: model.sign, appid: model.openApiAppId, orderNo: model.agreementNo, apiVersion: model.openApiAppVersion, licence: model.keyLicence, faceId: model.faceId, sdkConfig: getSDKSettings()){
//            WBFaceVerifyCustomerService.sharedInstance().startWbFaceVeirifySdk()
//    } failure:{ error in
//        print("\(error.description)")
//        }
//    }
//}
