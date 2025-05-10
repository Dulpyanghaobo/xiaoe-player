//
//  VerificationPopuoTwoView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit
import SnapKit

// 自定义弹窗系统的第二个视图
class VerificationPopuoTwoView: UIView {
    let titleLabel = UILabel()  // 顶部标题
    let leftImageView = UIImageView()  // 左侧图片
    let rightImageView = UIImageView() // 右侧图片
    let centerImageView = UIImageView() // 中间图片
    let descLabel = UILabel()   // 描述标签
    let stackListView = UIStackView() // 垂直堆栈视图
    let returnButton = UIButton() // 返回按钮

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        // 设置 titleLabel
        titleLabel.text = "欢迎来到实名认证"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)

        // 设置 ImageView
        leftImageView.contentMode = .scaleAspectFit
        rightImageView.contentMode = .scaleAspectFit
        centerImageView.contentMode = .scaleAspectFit

        // 设置 descLabel
        descLabel.text = "您已实名认证"
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 14)

        // 组织 stackListView
        stackListView.axis = .vertical
        stackListView.spacing = 10
        
        // 添加标签和文本框到 stackListView
        for i in 1...3 {
            let label = UILabel()
            label.text = "标签 \(i)"
            label.font = UIFont.systemFont(ofSize: 14)

            let textField = UITextField()
            textField.borderStyle = .roundedRect

            let stackItem = UIStackView(arrangedSubviews: [label, textField])
            stackItem.axis = .horizontal
            stackItem.spacing = 10
            stackItem.distribution = .fillEqually
            
            stackListView.addArrangedSubview(stackItem)
        }

        // 设置返回按钮
        returnButton.setTitle("返回", for: .normal)
        returnButton.backgroundColor = .systemBlue
        returnButton.setTitleColor(.white, for: .normal)
        returnButton.layer.cornerRadius = 5

        // 添加所有视图到主视图
        addSubview(titleLabel)
        addSubview(leftImageView)
        addSubview(rightImageView)
        addSubview(centerImageView)
        addSubview(descLabel)
        addSubview(stackListView)
        addSubview(returnButton)

        // 布局视图
        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }

        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.height.equalTo(50) // 设置图片大小
        }

        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.width.height.equalTo(50) // 设置图片大小
        }

        centerImageView.snp.makeConstraints { make in
            make.top.equalTo(leftImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview() // 与 titleLabel 的 centerX 对齐
            make.width.height.equalTo(100) // 设置中间图片大小
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(centerImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        stackListView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20) // 设置左右边距
        }

        returnButton.snp.makeConstraints { make in
            make.top.equalTo(stackListView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
}
