//
//  VerificationPopupThreeView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit
import SnapKit

// 自定义弹窗系统的第三个视图
class PopupThreeView: UIView {
    let backImageView = UIImageView()  // 背景图片
    let titleLabel = UILabel()  // 标题标签
    let descLabel = UILabel()  // 描述标签
    let retryButton = UIButton() // 重新认证按钮

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // 设置背景图片
        backImageView.contentMode = .scaleAspectFill
        backImageView.image = UIImage(named: "your_background_image_name") // 替换为你的图片名

        // 设置 titleLabel
        titleLabel.text = "抱歉，您的实名认证未通过！"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        // 设置 descLabel
        descLabel.text = "身份证识别错误！"
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 14)

        // 设置按钮
        retryButton.setTitle("重新认证", for: .normal)
        retryButton.backgroundColor = .systemBlue
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.layer.cornerRadius = 5

        // 添加视图到主视图
        addSubview(backImageView)
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(retryButton)

        // 布局视图
        setupConstraints()
    }

    private func setupConstraints() {
        backImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5) // 占据上半部分
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(backImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        retryButton.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
}
