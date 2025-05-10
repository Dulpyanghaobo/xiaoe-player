//
//  CustomerTextField.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
import SnapKit

class CustomerTextField: UIView {
    private let titleLabel = UILabel()
    private let textField = UITextField()
    
    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        setupViews(title: title, placeholder: placeholder)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews(title: String, placeholder: String) {
        titleLabel.text = title
        titleLabel.font = AppFonts.primary13Font
        titleLabel.textColor = AppColors.primpary170A0AColor
        addSubview(titleLabel)
        textField.borderStyle = .none
        textField.placeholder = placeholder
        textField.setLeftPaddingPoints(6) // 设置左边距为5px
        textField.backgroundColor = AppColors.primaryTextField01Color
        textField.textColor = AppColors.primpary3D3D3DColor
        textField.delegate = self
        addSubview(textField)

    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.equalTo(60)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(11)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
    }
    func setText(with text: String) {
        self.textField.text = text
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension CustomerTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
}
