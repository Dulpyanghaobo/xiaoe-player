//
//  QuestionCell.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//

import UIKit
import SnapKit
import AVFAudio

// 自定义CollectionViewCell
class QuestionCell: UICollectionViewCell {
    static let identifier = "QuestionCell"

    private let label = UILabel()
    private let chooseLabel = UILabel()

    // 用于保存默认的背景颜色
    private var originalBackgroundColor: UIColor?

    // 用于传递点击事件的闭包
    var onTap: ((String?) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGestureRecognizer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(chooseLabel)
        contentView.addSubview(label)

        chooseLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        label.snp.makeConstraints { make in
            make.left.equalTo(chooseLabel.snp.right).offset(4)
            make.centerY.equalToSuperview()
        }

        // 设置默认背景颜色
        originalBackgroundColor = .black
        chooseLabel.textColor = originalBackgroundColor
        label.textColor = originalBackgroundColor

    }

    private func setupGestureRecognizer() {
        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        // 改变背景颜色
        if chooseLabel.textColor == originalBackgroundColor {
            chooseLabel.textColor = AppColors.themeColor
            label.textColor = AppColors.themeColor
        } else {
            chooseLabel.textColor = originalBackgroundColor
            label.textColor = originalBackgroundColor
        }

        // 将 label.text 传递出去
        onTap?(label.text)
    }

    func configure(with text: String?, chooseLabel: String?) {
        label.text = text
        self.chooseLabel.text = chooseLabel
    }

}

// 自定义计算题Cell
class CalculationCell: UICollectionViewCell, UITextFieldDelegate  {
    static let identifier = "CalculationCell"

    private let label = UILabel()  // 题目Label
    private let textField = UITextField()  // 输入框
    private var cellType: CellType = .label // 默认是显示Label
    var onInputChanged: ((String) -> Void)?
    enum CellType {
        case label
        case input
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(label)
        contentView.addSubview(textField)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        textField.delegate = self // 设置代理

        label.font = AppFonts.primary14Font
        label.textColor = AppColors.primary343434BackColor
        textField.borderStyle = .roundedRect
        textField.isHidden = true  // 默认隐藏输入框
        setupKeyboardObservers()
        // 设置带有“隐藏键盘”按钮的工具栏
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        textField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        // 隐藏键盘
        textField.resignFirstResponder()
    }

    func configure(with text: String?, type: CellType) {
        self.cellType = type
        
        switch type {
        case .label:
            label.text = text
            label.isHidden = false
            textField.isHidden = true
        case .input:
            textField.placeholder = "请输入答案"
            textField.text = text
            label.isHidden = true
            textField.isHidden = false
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func getInputText() -> String? {
        return textField.text
    }
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // 调整布局，使输入框在键盘弹出时仍然可见
        let keyboardHeight = keyboardFrame.height
        // 例如，调整 contentView 或父视图的 bottom 约束
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // 键盘消失时，恢复布局
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // 回调用户输入的内容
        if let text = textField.text {
            onInputChanged?(text)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func resignFirstResponder() {
        self.textField.resignFirstResponder()
    }
    
    // UITextFieldDelegate 方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 在用户点击 "return" 键时关闭键盘
        self.textField.resignFirstResponder()
        return true
    }
}


class VoiceVerificationCell: UICollectionViewCell, UITextFieldDelegate {
    static let identifier = "VoiceVerificationCell"
    private var question: Int = 0

    private let inputField = UITextField() // 输入框
    private let listenButton = UIButton(type: .custom)
    private let synthesizer = AVSpeechSynthesizer()
    var onInputChanged: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(inputField)
        contentView.addSubview(listenButton)

        inputField.layer.cornerRadius = 4
        inputField.layer.borderWidth = 2
        inputField.layer.borderColor = AppColors.themeColor.cgColor
        inputField.delegate = self // 设置代理
        inputField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(listenButton.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }

        listenButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
        }

        listenButton.setTitle("再听一次", for: .normal)
        listenButton.setTitleColor(AppColors.themeColor, for: .normal)
        listenButton.layer.cornerRadius = 2
        listenButton.addTarget(self, action: #selector(listenButtonTapped), for: .touchUpInside)
        
        inputField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        // 设置带有“隐藏键盘”按钮的工具栏
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        inputField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        // 隐藏键盘
        inputField.resignFirstResponder()
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        // 调整布局，使输入框在键盘弹出时仍然可见
        let keyboardHeight = keyboardFrame.height
        // 例如，调整 contentView 或父视图的 bottom 约束
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // 键盘消失时，恢复布局
        
    }

    func configure(with question: Int) {
        self.question = question
    }
    
    @objc private func listenButtonTapped() {
        let utterance = AVSpeechUtterance(string: "\(question)")
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN") // 中文
        synthesizer.speak(utterance)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // 回调用户输入的内容
        if let text = textField.text {
            onInputChanged?(text)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func resignFirstResponder() {
        self.inputField.resignFirstResponder()
    }

    // UITextFieldDelegate 方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 在用户点击 "return" 键时关闭键盘
        textField.resignFirstResponder()
        return true
    }
}
