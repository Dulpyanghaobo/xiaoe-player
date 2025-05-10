//
//  ContactInfoCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//

import UIKit
import STTextView

class ContactInfoCell: UITableViewCell {

    private let contactTextView = STTextView()
    
    var onTextChanged: ((String) -> Void)?

    var onBeginEditing: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(contactTextView)
        contactTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
            make.height.equalTo(50)
        }
        contactTextView.delegate = self
        contactTextView.placeholderColor = .secondaryLabel
    }

    func configure(with text: String) {
        contactTextView.placeholder = text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        onBeginEditing?()
    }
}

extension ContactInfoCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}
