//
//  LoginViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/16/24.
//

import UIKit
import SnapKit
enum LoginType {
    case phoneLogin
    case accountLogin
}

class LoginViewController: BaseViewController,UITextViewDelegate {
    
    private let backgroundImageView = UIImageView()
    private let inputBackgroundImageView = UIImageView()

    private let titleLabel = UILabel()
    private let phoneLoginButton = UIButton(type: .custom)
    private let accountLoginButton = UIButton(type: .custom)
    private let accountTextField = CustomTextField(type: .account)
    private let passwordTextField = CustomTextField(type: .password)
    private let phoneTextField = CustomTextField(type: .phone)
    private let smsCodeTextField = CustomTextField(type: .smsCode)
    private let agreementCheckbox = UIButton()
    private let passwordToggleButton = UIButton(type: .custom)
    private let loginButton = UIButton()
    private let sendSmsButton = UIButton()
    
    private var loginType: LoginType = .phoneLogin
    private let authManager = AuthManager()
    private var captchaKey: String?
    var timer: Timer?
    private let viewModel = LoginViewModel()
    private let loadingView = LoadingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        setupUI()
        setupLoadingView()
        bindViewModel()
        loadLoginConfig()
    }
    
    
    private func loadLoginConfig() {
        loadingView.startLoading()
        viewModel.loadLoginUIConfig()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.tabBarController?.tabBar.isHidden == false {
            self.tabBarController?.tabBar.isHidden = true
        }
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupUI() {
        setupBackgroundImage()
        setupTitleLabel()
        setupSegmentedControl()
        setupTextField()
        setupLoginButton()
        setupPhoneLogin()
        updateLoginFieldsVisibility(for: self.loginType)
        setupDismissKeyboardGesture()
    }
    
    private func setupDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.image = UIImage(named: "back_ground_login")
        inputBackgroundImageView.image = UIImage.init(named: "input_background_01")
        backgroundImageView.contentMode = .scaleAspectFill
        inputBackgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.addSubview(inputBackgroundImageView)
    }
    
    private func setupSegmentedControl() {
        phoneLoginButton.setTitle("验证码登录", for: .normal)
        phoneLoginButton.setTitleColor(AppColors.themeColor, for: .normal)
        phoneLoginButton.titleLabel?.font = AppFonts.primary18Font
        phoneLoginButton.addTarget(self, action: #selector(phoneLoginButtonTapped), for: .touchUpInside)
        
        accountLoginButton.setTitle("账号登录", for: .normal)
        accountLoginButton.setTitleColor(AppColors.primaryFFF5F5Color, for: .normal) // 默认未选中颜色
        accountLoginButton.titleLabel?.font = AppFonts.primary18Font
        accountLoginButton.addTarget(self, action: #selector(accountLoginButtonTapped), for: .touchUpInside)
        view.addSubview(phoneLoginButton)
        view.addSubview(accountLoginButton)
        
        phoneLoginButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(56)
            make.centerX.equalToSuperview().offset(-screenWidth/4)
            make.width.equalTo(120)
            make.height.equalTo(56)
        }
        
        accountLoginButton.snp.makeConstraints { make in
            make.top.equalTo(phoneLoginButton)
            make.centerX.equalToSuperview().offset(screenWidth/4)
            make.width.equalTo(120)
            make.height.equalTo(56)
        }
        
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(accountLoginButton.snp.bottom).offset(54)
        }
        
        inputBackgroundImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(backgroundImageView.snp.bottom).offset(-97)
            make.bottom.equalToSuperview()
        }
    }
    private func setupTitleLabel() {
        titleLabel.text = "Hello!\n欢迎使用蚂蚁播放器"
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = AppFonts.primaryBiggestFont
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(statusBarHeight + 66)
        }
    }
    
    func setupTextField() {
        view.addSubview(accountTextField)
        view.addSubview(passwordTextField)
        view.addSubview(phoneTextField)
        view.addSubview(smsCodeTextField)
        accountTextField.delegate = self
        passwordTextField.delegate = self
        phoneTextField.delegate = self
        smsCodeTextField.delegate = self
        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLoginButton.snp.bottom).offset(85)
            make.left.right.equalToSuperview().inset(36)
            make.height.equalTo(48)
        }
        
        smsCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
            make.left.equalTo(phoneTextField)
            make.width.equalTo(phoneTextField)
            make.height.equalTo(48)
        }
        
        accountTextField.snp.makeConstraints { make in
            make.top.equalTo(phoneLoginButton.snp.bottom).offset(85)
            make.left.right.equalToSuperview().inset(36)
            make.height.equalTo(48)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(accountTextField.snp.bottom).offset(20)
            make.left.right.height.equalTo(accountTextField)
        }
    }
    
    @objc private func phoneLoginButtonTapped() {
        self.loginType = .phoneLogin
        updateLoginFieldsVisibility(for: self.loginType)
        self.inputBackgroundImageView.image = UIImage.init(named: "input_background_01")
        phoneLoginButton.setTitleColor(AppColors.themeColor, for: .normal)
        accountLoginButton.setTitleColor(AppColors.primaryFFF5F5Color, for: .normal)
    }

    @objc private func accountLoginButtonTapped() {
        self.loginType = .accountLogin
        updateLoginFieldsVisibility(for: self.loginType)
        self.inputBackgroundImageView.image = UIImage.init(named: "input_background_02")

        accountLoginButton.setTitleColor(AppColors.themeColor, for: .normal)
        phoneLoginButton.setTitleColor(AppColors.primaryFFF5F5Color, for: .normal)
    }

    
    private func updateLoginFieldsVisibility(for type: LoginType) {
        let isPhoneLogin = (type == .phoneLogin)

        phoneTextField.isHidden = !isPhoneLogin
        smsCodeTextField.isHidden = !isPhoneLogin
        
        accountTextField.isHidden = isPhoneLogin
        passwordTextField.isHidden = isPhoneLogin
        
        // 更新登录按钮的位置
        loginButton.snp.remakeConstraints { make in
            make.top.equalTo(isPhoneLogin ? smsCodeTextField.snp.bottom : passwordTextField.snp.bottom).offset(30)
            make.left.right.equalTo(isPhoneLogin ? phoneTextField : accountTextField)
            make.height.equalTo(44)
        }
    }
    
    private func setupAgreement(with config: LoginUIConfigResponse) {
        // 创建容器视图
        let agreementContainerView = UIView()

        // 配置 `agreementCheckbox`
        agreementCheckbox.setImage(UIImage(systemName: "circle"), for: .normal)
        agreementCheckbox.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        agreementCheckbox.addTarget(self, action: #selector(agreementCheckboxTapped), for: .touchUpInside)
        agreementCheckbox.tintColor = AppColors.themeColor
        
        // 创建富文本
        let agreementText = "我已同意并阅读《用户协议》和《隐私协议》"
        let attributedString = NSMutableAttributedString(string: agreementText)
        
        // 配置富文本
        let userAgreementRange = (agreementText as NSString).range(of: "《用户协议》")
        let privacyPolicyRange = (agreementText as NSString).range(of: "《隐私协议》")
        
        // 设置颜色
        attributedString.addAttribute(.foregroundColor, value: AppColors.themeColor, range: userAgreementRange)
        attributedString.addAttribute(.foregroundColor, value: AppColors.themeColor, range: privacyPolicyRange)
        
        // 设置字体
        let fullRange = NSRange(location: 0, length: agreementText.count)
        attributedString.addAttribute(.font, value: AppFonts.primary12Font, range: fullRange)
        
        // 设置可点击
        let userAgreementUrl = config.service_protocol_url
        let privacyPolicyUrl = config.personal_protocol_url
        
        attributedString.addAttribute(.link, value: userAgreementUrl, range: userAgreementRange)
        attributedString.addAttribute(.link, value: privacyPolicyUrl, range: privacyPolicyRange)
        let agreementTextView = UITextView()
        agreementTextView.attributedText = attributedString
        agreementTextView.isEditable = false
        agreementTextView.isScrollEnabled = false
        agreementTextView.backgroundColor = .clear
        agreementTextView.textAlignment = .left
        agreementTextView.linkTextAttributes = [
            .foregroundColor: AppColors.themeColor // 设置链接的颜色
        ]

        
        // 将 `agreementCheckbox` 和 `agreementLabel` 添加到容器视图中
        agreementContainerView.addSubview(agreementCheckbox)
        agreementContainerView.addSubview(agreementTextView)
        
        // 将容器视图添加到主视图中
        view.addSubview(agreementContainerView)
        
        // 布局容器视图
        agreementContainerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-88) // 调整这个值来适配屏幕底部的距离
        }
        
        // 布局 `agreementCheckbox` 和 `agreementLabel`
        agreementCheckbox.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        
        agreementTextView.snp.makeConstraints { make in
            make.left.equalTo(agreementCheckbox.snp.right).offset(8)
            make.bottom.equalToSuperview().offset(tabBarHeight) // 调整这个值来适配屏幕底部的距离
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
    }

    
    
       func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
           // 在这里处理链接点击事件
           if URL.absoluteString == viewModel.loginUIConfig?.service_protocol_url {
               // 用户协议链接被点击
               // 执行自定义操作，比如打开内嵌的WebView或进行其他逻辑处理
               openURL(URL)
               return false // 返回 false 阻止 UITextView 的默认行为
           } else if URL.absoluteString == viewModel.loginUIConfig?.personal_protocol_url {
               // 隐私协议链接被点击
               openURL(URL)
               return false
           }
           return true
       }
       
       private func openURL(_ url: URL) {
           // 自定义的 URL 打开逻辑，比如展示内嵌的 WebView
           SafariViewController().openURL(url, from: self)
       }
    
    @objc private func agreementCheckboxTapped() {
        viewModel.isAgreementAccepted.toggle()
        agreementCheckbox.isSelected = viewModel.isAgreementAccepted
    }
    
    private func setupLoginButton() {
        loginButton.setTitle("登录", for: .normal)
        loginButton.backgroundColor = AppColors.themeColor
        loginButton.layer.cornerRadius = 24
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        view.addSubview(loginButton)
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(smsCodeTextField.snp.bottom).offset(40)
            make.left.right.equalTo(accountTextField)
            make.height.equalTo(44)
        }
    }
    
    private func setupPhoneLogin() {
        phoneTextField.backgroundColor = AppColors.primaryTextField01Color
        accountTextField.backgroundColor = AppColors.primaryTextField01Color
        passwordTextField.backgroundColor = AppColors.primaryTextField01Color
        smsCodeTextField.backgroundColor = AppColors.primaryTextField01Color
        
        // Adjust login button constraints
        loginButton.snp.remakeConstraints { make in
            make.top.equalTo(smsCodeTextField.snp.bottom).offset(30)
            make.left.right.equalTo(phoneTextField)
            make.height.equalTo(44)
        }
    }
    private func bindViewModel() {
        
        viewModel.showError = { [weak self] message in
            self?.view.makeToast(message)
        }
        
        viewModel.showSuccess = { [weak self] message in
            self?.view.makeToast(message)
        }
        
        viewModel.jumpToHome = { [weak self] in
            self?.navigationController?.pushViewController(MainTabBarController(), animated: true)
        }
        
        viewModel.showWarning = { [weak self] message in
            self?.view.makeToast(message)
        }
        
        viewModel.configLoaded = { [weak self] response in
            self?.loadingView.stopLoading()
            guard let response = response else { return }
            self?.setupAgreement(with: response)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let defaultView = DefaultView(title: title, message: message, buttonTitles: [
            "确认": {
                print("确认按钮被点击")
            }
        ])
        PopupManager.shared.showPopup(PopupView(contentView: defaultView, popupType: .center, animationType: .fade))
    }
    
    
    
    @objc private func loginButtonTapped() {
        viewModel.phoneNumber = phoneTextField.getText() ?? ""
        viewModel.smsCode = smsCodeTextField.getText() ?? ""
        viewModel.username = accountTextField.getText() ?? ""
        viewModel.password = passwordTextField.getText() ?? ""
        viewModel.login(loginType: self.loginType)
    }
}

extension LoginViewController :CustomTextFieldDelegate {
    func sendSmsCode(completion: @escaping (Bool) -> Void) {
        viewModel.phoneNumber = phoneTextField.getText() ?? ""
        viewModel.sendSmsCode { isSuccess in
            completion(isSuccess)
        }
    }

}
