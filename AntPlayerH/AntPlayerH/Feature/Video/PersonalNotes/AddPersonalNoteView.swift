//
//  AddPersonalNoteView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/31/24.
//

import UIKit
import SnapKit
import STTextView

class AddPersonalNoteView: UIView {
    private let titleLabel = UILabel()
    private let saveButton = UIButton(type: .system)
    private let publishButton = UIButton(type: .system)
    private let titleTextView = STTextView()
    private let contentTextView = STTextView()

    var onSave: ((String, String) -> Void)?
    var onPublish: ((String, String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .white

        // 配置标题标签
        titleLabel.text = "我的笔记"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        addSubview(titleLabel)

        // 配置保存按钮
        saveButton.setTitle("保存", for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        addSubview(saveButton)

        // 配置发布按钮
        publishButton.setTitle("发布", for: .normal)
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        addSubview(publishButton)

        // 配置标题输入框
        titleTextView.placeholder = "输入标题"
        titleTextView.placeholderColor = .lightGray
        titleTextView.font = UIFont.systemFont(ofSize: 18)
        addSubview(titleTextView)

        // 配置内容输入框
        contentTextView.placeholder = "写点什么..."
        contentTextView.placeholderColor = .lightGray
        contentTextView.font = UIFont.systemFont(ofSize: 16)
        addSubview(contentTextView)

        // 使用 SnapKit 设置约束
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.centerX.equalToSuperview()
        }

        saveButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.left.equalToSuperview().offset(16)
        }

        publishButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        titleTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextView.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    @objc private func saveButtonTapped() {
        guard let title = titleTextView.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            // 提示用户输入完整信息
            return
        }
        onSave?(title, content)
    }

    @objc private func publishButtonTapped() {
        guard let title = titleTextView.text, !title.isEmpty,
              let content = contentTextView.text, !content.isEmpty else {
            // 提示用户输入完整信息
            return
        }
        onPublish?(title, content)
    }
}
