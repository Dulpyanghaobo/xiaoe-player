//
//  PersonalNoteBottomView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/31/24.
//

import UIKit
import SnapKit

@available(iOS 16.0, *)
class PersonalNoteBottomView: UIView {
    private let button = UIButton(type: .custom)
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.borderColor = AppColors.themeColor.cgColor
        // 配置图标
        iconImageView.image = UIImage(systemName: "pencil")?.withTintColor(AppColors.themeColor, renderingMode: .alwaysOriginal)
        button.addSubview(iconImageView)

        // 配置标题标签
        titleLabel.text = "我要记笔记"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = AppColors.themeColor
        button.addSubview(titleLabel)

        // 配置按钮
        button.layer.borderWidth = 1.0
        button.layer.borderColor = AppColors.themeColor.cgColor
        button.layer.cornerRadius = 10.0
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(button)

        // 使用 SnapKit 设置约束
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        iconImageView.snp.makeConstraints { make in
            make.left.equalTo(button.snp.centerX).offset(-44)
            make.centerY.equalTo(button.snp.centerY)
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(8)
            make.centerY.equalTo(button.snp.centerY)
        }
    }

    @objc private func buttonTapped() {
        onTap?()
    }
}
