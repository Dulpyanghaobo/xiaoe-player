//
//  EmptyView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/26/24.
//
import UIKit
import SnapKit

class EmptyView: UIView {
    private let imageView = UIImageView()
    private let messageLabel = UILabel()
    var tableView: UITableView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 设置 ImageView
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "empty_icon") // 替换为你的图片名
        addSubview(imageView)

        // 设置 MessageLabel
        messageLabel.text = "还没有人记录笔记,赶紧去记录下学习笔记吧~"
        messageLabel.font = AppFonts.primary12Font
        messageLabel.textColor = AppColors.primaryDCDCDCBackColor
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)

        // 使用 SnapKit 设置约束
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(231)
            make.height.equalTo(178)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 检查是否点击在 EmptyView 的范围内
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            // 如果点击在 EmptyView 上，返回 tableView 以允许滑动
            return tableView
        }
        return hitView
    }
}

