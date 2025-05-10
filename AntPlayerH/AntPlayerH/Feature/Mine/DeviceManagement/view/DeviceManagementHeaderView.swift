//
//  DeviceManagementHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
import SnapKit
import Kingfisher

class DeviceManagementHeaderView: UIView {
    private let backgourdImageView03 = UIImageView(image: UIImage(named: "default_image"))
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgourdImageView03.layer.cornerRadius = 27
        backgourdImageView03.clipsToBounds = true
        addSubview(backgourdImageView03)
        // 设置头像
        avatarImageView.layer.cornerRadius = 27
        avatarImageView.clipsToBounds = true
        addSubview(avatarImageView)

        // 设置用户名
        nameLabel.text = "用户名" // 替换为实际的用户名
        nameLabel.font = AppFonts.primaryBiggestFont
        nameLabel.textAlignment = .center
        addSubview(nameLabel)

        // 设置描述标签
        descLabel.text = "本账号登录过的设备信息，对不熟悉或不常用的设备退出登录，避免隐私泄露，保护网盘资产安全。"
        descLabel.textAlignment = .left
        descLabel.font = AppFonts.primary12Font
        descLabel.textColor = AppColors.primpary999999Color
        descLabel.numberOfLines = 0
        addSubview(descLabel)

        // 设置约束
        setupConstraints()
    }

    private func setupConstraints() {
        
        backgourdImageView03.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(64)
        }
        avatarImageView.snp.makeConstraints { make in
            make.center.equalTo(backgourdImageView03)
            make.width.height.equalTo(54)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
    }
    
    func configure(with imageString: String, name: String, desc: String) {
        if let imageUrl = URL(string: imageString ?? "") {
            avatarImageView.kf.setImage(with: imageUrl)
         }
        nameLabel.text = name
        descLabel.text = desc
    }
}
