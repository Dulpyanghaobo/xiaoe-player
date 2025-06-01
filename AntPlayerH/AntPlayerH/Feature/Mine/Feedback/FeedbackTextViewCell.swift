//
//  FeedbackTextViewCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//

import UIKit
import STTextView
import SnapKit

class FeedbackTextViewCell: UITableViewCell {
    let textView = STTextView()
    let imagePickerView = ImagePickerView()
    
    var onTextChanged: ((String) -> Void)?
    var onImagesChanged: (([UIImage]) -> Void)?

    var onBeginEditing: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentView.addSubview(textView)
        contentView.addSubview(imagePickerView)
        
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(100)
        }
        
        imagePickerView.snp.makeConstraints { make in
            make.top.equalTo(textView.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(70)
            make.bottom.equalToSuperview().inset(10)
        }
        
        textView.delegate = self
        textView.backgroundColor = AppColors.primaryBackgroundColor
        textView.layer.cornerRadius = 8
        imagePickerView.onImageAdded = { [weak self] image in
            self?.onImagesChanged?([image])
        }
    }
    
    func configure(with text: String) {
        textView.text = text
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        onBeginEditing?()
    }
}

extension FeedbackTextViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        onTextChanged?(textView.text)
    }
}
