//
//  BottomView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/31/24.
//

import UIKit
import STTextView
import SnapKit

class CommentInputView: UIView {
    let textView = STTextView()
    let sendButton = UIButton(type: .custom)
    
    var onTextChanged: ((String) -> Void)?
    var onSend: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .white
        // 配置 textView
        textView.font = AppFonts.primaryDesc2Font
        textView.placeholder = "说点什么吧~"
        textView.placeholderColor = AppColors.primpary808080Color
        textView.backgroundColor = AppColors.primparyF7F7F7Color
        textView.delegate = self
        addSubview(textView)

        // 配置 sendButton
        sendButton.setTitle("发布", for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.setTitleColor(.gray, for: .normal)
        sendButton.titleLabel?.font = AppFonts.primary14Font
        addSubview(sendButton)

        // 使用 SnapKit 设置约束
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendButton.snp.leading).offset(-8)
            make.height.equalTo(36)
        }

        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(textView)
            make.width.equalTo(60)
        }
    }

    @objc private func sendButtonTapped() {
        guard let text = textView.text, !text.isEmpty else {
            // 显示错误或提示用户输入内容
            return
        }
        onSend?(text)
        textView.text = ""
    }
}

extension CommentInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}
