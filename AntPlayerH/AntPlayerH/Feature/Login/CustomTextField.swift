//
//  TextFieldFactory.swift
//  AntPlayerH
//
//  Created by i564407 on 7/22/24.
//

import UIKit
import SnapKit

protocol CustomTextFieldDelegate: AnyObject {
    func sendSmsCode(completion: @escaping (Bool) -> Void)
}

enum SendSmsButtonState {
    case readyToSend
    case countdown(Int)
}


enum TextFieldType {
    case account
    case password
    case phone
    case smsCode
}

class CustomTextField: UIView {
    var sendSmsButton = UIButton(type: .custom)

    private let textField = UITextField()
    private let type: TextFieldType
    weak var delegate: CustomTextFieldDelegate?
    private var sendSmsButtonState: SendSmsButtonState = .readyToSend {
        didSet {
            updateButtonStatus()
        }
    }
    var remainingTime: Int = 60

    init(type: TextFieldType) {
        self.type = type
        super.init(frame: .zero)
        setupTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTextField() {
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.tintColor = AppColors.themeColor
        textField.backgroundColor = AppColors.primaryTextField01Color
        switch type {
        case .account:
            textField.placeholder = "请输入账号"
        case .password:
            textField.placeholder = "请输入密码"
            textField.isSecureTextEntry = true
            let passwordToggleButton = UIButton(type: .custom)
            let slashConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular, scale: .large)
            let slashImage = UIImage(systemName: "eye.slash", withConfiguration: slashConfig)
            let eyeConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular, scale: .large)
            let eyeImage = UIImage(systemName: "eye", withConfiguration: eyeConfig)
            passwordToggleButton.setImage(slashImage, for: .normal)
            passwordToggleButton.setImage(eyeImage, for: .selected)
            passwordToggleButton.addTarget(self, action: #selector(togglePasswordVisibility(_:)), for: .touchUpInside)
            passwordToggleButton.tintColor = AppColors.primaryBackground01Color
            
            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            passwordToggleButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            passwordToggleButton.center = CGPoint(x: rightViewContainer.bounds.midX, y: rightViewContainer.bounds.midY)
            rightViewContainer.addSubview(passwordToggleButton)
            textField.rightView = rightViewContainer
            textField.rightViewMode = .always
        case .phone:
            textField.placeholder = "请输入手机号"
        case .smsCode:
            textField.placeholder = "请输入验证码"
            let sendSmsButton = UIButton(type: .custom)
            self.sendSmsButton = sendSmsButton
            sendSmsButton.setTitle("发送验证码", for: .normal)
            sendSmsButton.titleLabel?.font = AppFonts.primaryTitleFont
            sendSmsButton.setTitleColor(AppColors.themeColor, for: .normal)
            sendSmsButton.backgroundColor = .white
            sendSmsButton.layer.cornerRadius = 8
            sendSmsButton.addTarget(self, action: #selector(sendSmsButtonTapped(_:)), for: .touchUpInside)
            let rightViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 44))
            sendSmsButton.frame = CGRect(x: 0, y: 0, width: 98, height: 36)
            sendSmsButton.center = CGPoint(x: rightViewContainer.bounds.midX, y: rightViewContainer.bounds.midY)
            rightViewContainer.addSubview(sendSmsButton)
            textField.rightView = rightViewContainer
            textField.rightViewMode = .always
        }
        
        addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func togglePasswordVisibility(_ sender: UIButton) {
        textField.isSecureTextEntry.toggle()
        sender.isSelected = !textField.isSecureTextEntry
    }
    
    @objc private func sendSmsButtonTapped(_ sender: UIButton) {
        delegate?.sendSmsCode(completion: { [weak self] isSuccess in
            if isSuccess {
                self?.sendSmsButtonState = .countdown(self?.remainingTime ?? 60)
                self?.startCountdown(sender: sender)
            }
        })
    }
    
    func getText() -> String? {
        return textField.text
    }
    func resignFirstResponder() {
        textField.resignFirstResponder()
    }
    
    func startCountdown(sender: UIButton) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.remainingTime -= 1
            sender.setTitle("已发送(\(self.remainingTime)s)", for: .normal)
            if self.remainingTime <= 0 {
                timer.invalidate()
                sendSmsButtonState = .readyToSend
                
            }
        }
    }
    
    func updateButtonStatus() {
        switch sendSmsButtonState {
        case .readyToSend:
            sendSmsButton.setTitle("发送验证码", for: .normal)
            sendSmsButton.setTitleColor(AppColors.themeColor, for: .normal)
            sendSmsButton.backgroundColor = .white
            sendSmsButton.isEnabled = true
            self.remainingTime = 60
        case .countdown(let timeLeft):
            sendSmsButton.setTitle("已发送(\(timeLeft)s)", for: .normal)
            sendSmsButton.setTitleColor(AppColors.primparyCCCCCCColor, for: .normal)
            sendSmsButton.backgroundColor = AppColors.primaryF5F5F5Color
            sendSmsButton.isEnabled = false
        }
    }
    
}
