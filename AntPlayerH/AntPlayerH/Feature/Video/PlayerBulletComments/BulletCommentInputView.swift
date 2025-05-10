//
//  KeyboardViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/18/24.
//

import UIKit
import SnapKit
import STTextView

class BulletCommentInputView: UIView {
    let textView = STTextView()
    let sendButton = UIButton(type: .custom)
    let settingButton = UIButton(type: .custom)
    var onSettingButtonTapped: (() -> Void)?

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
        self.backgroundColor = UIColor.init(hex: "F4F4F4")
        // 配置 textView
        textView.font = AppFonts.primaryDesc2Font
        textView.placeholder = "发个友善的弹幕见证当下"
        textView.placeholderColor = AppColors.primpary808080Color
        textView.backgroundColor = AppColors.primparyF7F7F7Color
        textView.delegate = self
        addSubview(textView)

        // 配置 sendButton
        sendButton.setImage(UIImage(systemName: "paperplane")?.withTintColor(.gray, renderingMode: .alwaysOriginal), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        addSubview(sendButton)

        
        // 配置 settingButton (按钮A)
        settingButton.setImage(UIImage(systemName: "textformat")?.withTintColor(AppColors.themeColor, renderingMode: .alwaysOriginal), for: .normal)
        settingButton.addTarget(self, action: #selector(settingButtonTapped), for: .touchUpInside)
        addSubview(settingButton)
        
        
        // 使用 SnapKit 设置约束
        settingButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalTo(textView)
            make.width.equalTo(36)
        }

        // 使用 SnapKit 设置约束
        textView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.equalTo(settingButton.snp.trailing).offset(16)
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
    
    @objc private func settingButtonTapped() {
        // 隐藏键盘
        textView.resignFirstResponder()
        onSettingButtonTapped?()
    }

}

extension BulletCommentInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}
