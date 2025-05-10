//
//  AdpopupView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//

import UIKit
import SnapKit

class AdPopupView: UIView {
    
    private let adLabel = UILabel()  // 广告Label
    private let closeButton = UIButton(type: .custom)  // 关闭按钮
    private let adImageView = UIImageView()  // 广告图片

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()  // 设置视图
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // 设置背景
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true

        // 设置广告Label
        adLabel.text = "这是广告"  // 可以根据需要修改广告标题
        adLabel.font = UIFont.boldSystemFont(ofSize: 16)
        adLabel.textColor = .black
        addSubview(adLabel)

        // 设置关闭按钮
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.red, for: .normal)
        closeButton.addTarget(self, action: #selector(dismissPopup), for: .touchUpInside)
        addSubview(closeButton)

        // 设置广告图片
        adImageView.image = UIImage(named: "ad_image")  // 用你的广告图片替换
        adImageView.contentMode = .scaleAspectFill
        addSubview(adImageView)

        // 使用SnapKit设置布局
        setupConstraints()
    }

    private func setupConstraints() {
        adLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }

        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(-16)
        }

        adImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc private func dismissPopup() {
        self.removeFromSuperview()
    }

    func show(in view: UIView) {
        view.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()  // 使其完全覆盖父视图
        }
    }
}
