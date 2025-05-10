//
//  CourseSearchView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/8/24.
//
import UIKit

class CourseSearchView: UIView {
    let titleLabel = UILabel()
    let courseNameTextField = UITextField()
    let buttonStackView = UIStackView()
    var onSearch: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true

        // 设置标题
        titleLabel.text = "请输入课程名称"
        titleLabel.font = AppFonts.primaryTitleFont
        titleLabel.textAlignment = .center

        // 设置文本框
        courseNameTextField.placeholder = "课程名称"
        courseNameTextField.textAlignment = .center

        // 设置按钮
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("搜索", for: .normal)
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = AppColors.primparyDBDBDBColor.cgColor
        searchButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        searchButton.titleLabel?.font = AppFonts.primaryTitleFont
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        cancelButton.titleLabel?.font = AppFonts.primaryTitleFont
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = AppColors.primparyDBDBDBColor.cgColor
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        // 设置按钮堆栈
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.addArrangedSubview(searchButton)
        buttonStackView.addArrangedSubview(cancelButton)

        // 添加子视图
        addSubview(titleLabel)
        addSubview(courseNameTextField)
        addSubview(buttonStackView)

        // 布局约束使用 SnapKit
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(63)
        }
        courseNameTextField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
        }
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(courseNameTextField.snp.bottom).offset(17)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(0)
            make.height.equalTo(44)
        }
    }

    @objc private func searchButtonTapped() {
        guard let courseName = courseNameTextField.text, !courseName.isEmpty else { return }
        onSearch?(courseName)
    }

    @objc private func cancelButtonTapped() {
        // 关闭弹窗
        if let popupView = self.superview as? PopupView {
            popupView.dismiss()
        }
    }
}
