//
//  AboutAppViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
import SnapKit

class AboutAppViewController: BaseViewController {
    
    private let logoImageView = UIImageView()
    private let titleLabel = UILabel()
    private let versionLabel = UILabel()
    private let copyWeChatButton = UIButton(type: .system)
    private let weChatLabel = UILabel()
    private let qqGroupLabel = UILabel()
    
    private let bottomView = UIView()
    private let websiteButton = UIButton(type: .system)
    private let privacyButton = UIButton(type: .system)
    private let termsButton = UIButton(type: .system)
    private let companyLabel = UILabel()
    private let copyrightLabel = UILabel()
    private let safariVC = SafariViewController()

    private let aboutAppModel: AboutAppResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        guard let model = self.aboutAppModel else { return }
        configData(model: model)
    }
    
    init(aboutAppModel: AboutAppResponse?) {
        self.aboutAppModel = aboutAppModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        title = "关于应用"
        view.backgroundColor = .white
        
        // Logo
        view.addSubview(logoImageView)
        logoImageView.image = UIImage(named: "ant_logo")
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationFullHeight+44)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        // Title
        view.addSubview(titleLabel)
        titleLabel.text = "蚂蚁播放器"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        titleLabel.textAlignment = .center
        titleLabel.textColor = AppColors.themeColor
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        // Version
        view.addSubview(versionLabel)
        versionLabel.text = "版本号 V1.0.0_20211201"
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textAlignment = .center
        versionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
        }
        
        // WeChat Button
        view.addSubview(copyWeChatButton)
        copyWeChatButton.setTitle("复制官网客服微信", for: .normal)
        copyWeChatButton.addTarget(self, action: #selector(copyWeChatTapped), for: .touchUpInside)
        copyWeChatButton.setTitleColor(.white, for: .normal)
        copyWeChatButton.backgroundColor = AppColors.themeColor
        copyWeChatButton.layer.cornerRadius = 8
        copyWeChatButton.snp.makeConstraints { make in
            make.top.equalTo(versionLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(36)
            make.width.equalTo(200)
        }
        
        // WeChat Label
        view.addSubview(weChatLabel)
        weChatLabel.text = "客服微信：xxxxxxxx"
        weChatLabel.font = UIFont.systemFont(ofSize: 14)
        weChatLabel.textColor = AppColors.primpary999999Color
        weChatLabel.snp.makeConstraints { make in
            make.top.equalTo(copyWeChatButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // QQ Group Label
        view.addSubview(qqGroupLabel)
        qqGroupLabel.text = "官方QQ群：xxxxxxxx"
        qqGroupLabel.font = UIFont.systemFont(ofSize: 14)
        qqGroupLabel.textColor = AppColors.primpary999999Color
        qqGroupLabel.snp.makeConstraints { make in
            make.top.equalTo(weChatLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // Bottom View
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        // Website Button
        bottomView.addSubview(websiteButton)
        websiteButton.setTitle("官方网站", for: .normal)
        websiteButton.setTitleColor(AppColors.themeColor, for: .normal)
        websiteButton.addTarget(self, action: #selector(websiteTapped), for: .touchUpInside)
        
        // Privacy Button
        bottomView.addSubview(privacyButton)
        privacyButton.setTitle("隐私策略", for: .normal)
        privacyButton.setTitleColor(AppColors.themeColor, for: .normal)

        privacyButton.addTarget(self, action: #selector(privacyTapped), for: .touchUpInside)
        
        // Terms Button
        bottomView.addSubview(termsButton)
        termsButton.setTitle("用户协议", for: .normal)
        termsButton.setTitleColor(AppColors.themeColor, for: .normal)

        termsButton.addTarget(self, action: #selector(termsTapped), for: .touchUpInside)
        
        // Arrange buttons horizontally
        let buttonStackView = UIStackView(arrangedSubviews: [websiteButton, privacyButton, termsButton])
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .equalSpacing
        bottomView.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }
        
        // Company Label
        bottomView.addSubview(companyLabel)
        companyLabel.text = "精诚捷创 版权所有"
        companyLabel.font = UIFont.systemFont(ofSize: 12)
        companyLabel.textAlignment = .center
        companyLabel.textColor = AppColors.primpary808080Color
        companyLabel.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // Copyright Label
        bottomView.addSubview(copyrightLabel)
        copyrightLabel.text = "Copyright © 2013-2021 JingChengJieChuang ALL Rights Reserved"
        copyrightLabel.font = UIFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = AppColors.primpary808080Color
        copyrightLabel.textAlignment = .center
        copyrightLabel.snp.makeConstraints { make in
            make.top.equalTo(companyLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    private func configData(model: AboutAppResponse) {
        copyrightLabel.text = model.copyright_en
        companyLabel.text = model.copyright_cn
        termsButton.setTitle(model.tips2_txt, for: .normal)
        websiteButton.setTitle(model.tips1_txt, for: .normal)
        termsButton.setTitle(model.tips3_txt, for: .normal)
        versionLabel.text = model.software_version
        titleLabel.text = model.software_name
        weChatLabel.text = model.text1
        qqGroupLabel.text = model.text2
        copyWeChatButton.setTitle(model.btn_text, for: .normal)
    }
    
    @objc private func copyWeChatTapped() {
        view.makeToast("复制成功", duration: 0.66, position: .bottom) {[weak self]_ in
            UIPasteboard.general.string = self?.weChatLabel.text
        }
    }
    
    @objc private func websiteTapped() {
        if let url = URL(string: self.aboutAppModel?.tips1_value ?? "") {
            safariVC.openURL(url, from: self)
        }
    }

    @objc private func privacyTapped() {
        if let url = URL(string: self.aboutAppModel?.tips2_value ?? "") {
            safariVC.openURL(url, from: self)
        }
    }

    @objc private func termsTapped() {
        if let url = URL(string: self.aboutAppModel?.tips3_value ?? "") {
            safariVC.openURL(url, from: self)
        }
    }
}


