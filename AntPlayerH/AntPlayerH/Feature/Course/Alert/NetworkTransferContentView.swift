//
//  NetworkTransferContentView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/8/24.
//

import UIKit

class NetworkTransferContentView: UIView {
    let titleLabel = UILabel()
    let urlTextField = UITextField()
    let buttonStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configText(with text: String) {
        self.urlTextField.placeholder = text
    }

    private func setupViews() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // 设置标题
        titleLabel.text = "请在网页输入一下地址"
        titleLabel.font = AppFonts.primaryTitleFont
        titleLabel.textAlignment = .center

        // 设置文本框
        urlTextField.placeholder = "http://" + (SystemDeviceConfig.getLastLoginIp() ?? "192.0.0.1") + ":8080/upload"
        urlTextField.textAlignment = .center

        // 设置按钮
        let copyButton = UIButton(type: .system)
        copyButton.setTitle("复制去粘贴", for: .normal)
        copyButton.layer.borderWidth = 1
        copyButton.layer.borderColor = AppColors.primparyDBDBDBColor.cgColor
        copyButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        copyButton.titleLabel?.font = AppFonts.primaryTitleFont
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        cancelButton.titleLabel?.font = AppFonts.primaryTitleFont
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = AppColors.primparyDBDBDBColor.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        // 设置按钮堆栈
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.addArrangedSubview(copyButton)
        buttonStackView.addArrangedSubview(cancelButton)

        // 添加子视图
        addSubview(titleLabel)
        addSubview(urlTextField)
        addSubview(buttonStackView)

        // 布局约束使用 SnapKit
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(63)
        }
        urlTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
        }
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(urlTextField.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(44)
        }
    }

    @objc private func copyButtonTapped() {
        guard let urlText = urlTextField.text else { return }
        UIPasteboard.general.string = urlText
    }

    @objc private func cancelButtonTapped() {
        // 关闭弹窗
        if let popupView = self.superview as? PopupView {
            popupView.dismiss()
        }
    }
}
