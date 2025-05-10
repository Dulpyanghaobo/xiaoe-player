//
//  IdentityVerificationViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
import SnapKit

class IdentityVerificationViewController: BaseViewController {
    
    private let scrollView = UIScrollView.init()
    private let contentView = UIView()
    private let idCardView = UIView()
    private let idCardFrontView = IDCardView(frame: .zero, initialImage: UIImage(named: "idCard_front"), type: 1)
    private let idCardBackView = IDCardView(frame: .zero, initialImage: UIImage.init(named: "idCard_back"), type: 2)
    private let underline = UIView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let realNameField = CustomerTextField(title: "真实姓名", placeholder: "请输入真实姓名")
    private let idCardNumberField = CustomerTextField(title: "身份证号", placeholder: "请输入身份证号")
    private let faceRecognitionButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "身份认证"
        self.navigationBarStyle = .whiteStyle
        setupViews()
        setupConstraints()
        setupKeyboardNotifications()
    }
    
    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.backgroundColor = .white
        scrollView.addSubview(contentView)
        idCardView.backgroundColor = AppColors.themeColor
        contentView.addSubview(idCardView)
        idCardView.addSubview(idCardFrontView)
        idCardFrontView.delegate = self
        idCardBackView.delegate = self
        idCardView.addSubview(idCardBackView)
        titleLabel.text = "身份验证"
        titleLabel.font = AppFonts.primary18Font
        titleLabel.textColor = AppColors.primpary646464Color
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        underline.backgroundColor = AppColors.primaryDCDCDCBackColor
        contentView.addSubview(underline)
        
        descLabel.text = "必须本人的有效身份证，与基本信息一致\n\n照片确保身份证边框完整，字体清晰，亮度均匀\n\n照片要求5M以内，支持 jpg / jpeg / png 格式"
        descLabel.font = AppFonts.primary12Font
        descLabel.textColor = AppColors.primpary808080Color
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .left
        contentView.addSubview(descLabel)
        contentView.addSubview(realNameField)
        contentView.addSubview(idCardNumberField)
        contentView.addSubview(faceRecognitionButton)
        faceRecognitionButton.setTitle("人脸认证", for: .normal)
        faceRecognitionButton.backgroundColor = AppColors.themeColor
        faceRecognitionButton.setTitleColor(.white, for: .normal)
        faceRecognitionButton.layer.cornerRadius = 22
        faceRecognitionButton.addTarget(self, action: #selector(faceRecognitionButtonTapped), for: .touchUpInside)
        scrollView.contentSize = CGSize.init(width: screenWidth, height: screenHeight - statusBarHeight)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationFullHeight)
            make.bottom.left.right.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize.init(width: screenWidth, height: screenHeight))
        }
        
        idCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview()
            make.height.equalTo(idCardView.snp.width).multipliedBy(0.75) // 高度自适应
        }
        
        idCardFrontView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(44)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        idCardBackView.snp.makeConstraints { make in
            make.top.equalTo(idCardFrontView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(idCardView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        underline.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(underline.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }
        
        realNameField.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(53)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        idCardNumberField.snp.makeConstraints { make in
            make.top.equalTo(realNameField.snp.bottom).offset(4)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    
        faceRecognitionButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(idCardNumberField.snp.bottom).offset(30)
            make.height.equalTo(44)
        }
    }
    
    @objc private func faceRecognitionButtonTapped() {
        let authManager = AuthManager()
        authManager.getFaceSdkSign(bizType: 1) { result in
            switch result {
            case .success(let response):
                let model = response.data
                let viewController = WBFaceViewController(faceSdkSignResponse: model)
                self.navigationController?.pushViewController(viewController, animated: true)
            case .failure(let error):
                print("Failed to fetch personal notes: \(error)")
            }
        }
        // 人脸认证按钮点击事件处理
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension IdentityVerificationViewController : IDCardViewDelegate {
    func didRecognizeIDCard(info: UploadSfzResponse, type: Int) {
        if type == 1 {
            realNameField.setText(with: info.name ?? "")
            idCardNumberField.setText(with: info.idNum ?? "")
        }
    }
}
