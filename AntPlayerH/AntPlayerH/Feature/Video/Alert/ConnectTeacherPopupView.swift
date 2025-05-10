//
//  File.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//

import UIKit
import SnapKit

class ConnectTeacherPopupView: UIView {
    
    private let backgroundView = UIView()
    private let titleLabel = UILabel()

    private let topView = UIView()
    private let backgroundColorView = UIView()

    private let stackView = UIStackView()
    private let closeButton = UIButton(type: .custom)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // 设置背景视图
        backgroundView.backgroundColor = .clear

        addSubview(backgroundView)
        topView.backgroundColor = .white
        backgroundView.addSubview(topView)
        topView.layer.cornerRadius = 28
        topView.clipsToBounds = true
        backgroundColorView.backgroundColor = AppColors.themeColor
        self.backgroundColorView.addSubview(titleLabel)
        titleLabel.textColor = .white
        titleLabel.text = "联系老师"
        titleLabel.font = AppFonts.primary21Font
        topView.addSubview(backgroundColorView)
        topView.addSubview(stackView)
        // 设置 StackView
        stackView.axis = .vertical
        stackView.spacing = 10
        
        // 添加内容
        addContent()
        
        // 添加关闭按钮
        closeButton.setImage(UIImage(named: "close"), for: .normal) // 这里使用关闭图标
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        backgroundView.addSubview(closeButton)
        
        // 布局
        setupConstraints(closeButton: closeButton)
    }
    
    private func addContent() {
        let items = [
            ("QQ", "精创", "复制QQ"),
            ("手机号码", "18565856585", "复制手机号"),
            ("微信号", "xxxx", "复制微信号")
        ]
        
        for (title, name, buttonTitle) in items {
            let rowView = createRow(title: title, name: name, buttonTitle: buttonTitle)
            stackView.addArrangedSubview(rowView)
        }
    }
    
    private func createRow(title: String, name: String, buttonTitle: String) -> UIView {
        let rowView = UIView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = AppColors.primary666666Color
        titleLabel.font = AppFonts.primary13Font
        titleLabel.textAlignment = .right
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = AppFonts.primary13Font
        nameLabel.textColor = AppColors.primary999999Color
        nameLabel.textAlignment = .left
        
        let copyButton = UIButton(type: .custom)
        copyButton.layer.cornerRadius = 10
        copyButton.setTitle(buttonTitle, for: .normal)
        copyButton.titleLabel?.font = AppFonts.primaryDesc2Font
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.backgroundColor = AppColors.themeColor
        copyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

        copyButton.addTarget(self, action: #selector(copyToClipboard(_:)), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, nameLabel, copyButton])
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        self.addSubview(stack)

        rowView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return rowView
    }
    
    private func setupConstraints(closeButton: UIButton) {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        topView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(232)
        }
        backgroundColorView.snp.makeConstraints { make in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(82)
        }
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        stackView.snp.makeConstraints { make in
            make.top.equalTo(backgroundColorView.snp.bottom).offset(20)
            make.leading.equalTo(backgroundColorView).offset(20)
            make.trailing.equalTo(backgroundColorView).offset(-20)
        }
        
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(56)
            make.centerX.equalTo(topView)
        }
    }
    
    @objc private func copyToClipboard(_ sender: UIButton) {
        guard let button = sender.titleLabel?.text else { return }
        UIPasteboard.general.string = button
        print("\(button) copied to clipboard")
    }
    
    @objc private func dismissPopup() {
        self.removeFromSuperview()
    }
}
