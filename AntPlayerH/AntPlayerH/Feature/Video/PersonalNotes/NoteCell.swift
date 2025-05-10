//
//  NoteCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/29/24.
//

import UIKit

class NoteCell: UITableViewCell {
        private let titleLabel = UILabel()
        private let descLabel = UILabel()
        private let commentLabel = UILabel()

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(descLabel)
            contentView.addSubview(commentLabel)
            commentLabel.numberOfLines = 0

            titleLabel.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(8)
                make.top.equalToSuperview().offset(4)
                make.right.equalToSuperview().offset(-10)
            }

            descLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(4)
                make.left.equalTo(titleLabel)
                make.right.equalTo(titleLabel)
            }

            commentLabel.snp.makeConstraints { make in
                make.top.equalTo(descLabel.snp.bottom).offset(4)
                make.left.equalTo(titleLabel)
                make.right.equalTo(titleLabel)
            }
            titleLabel.font = AppFonts.primary14Font
            titleLabel.textColor = AppColors.primary343434BackColor
            descLabel.font = AppFonts.primary12Font
            descLabel.textColor = AppColors.primaryDCDCDCBackColor
        }

        func configure(with comment: NoteRecord) {
            titleLabel.text = comment.userName
            descLabel.text = comment.contentTime
            // 将 HTML 内容转换为 NSAttributedString
            if let htmlData = comment.content.data(using: .utf8) {
                do {
                    let attributedString = try NSAttributedString(data: htmlData,
                                                                   options: [.documentType: NSAttributedString.DocumentType.html,
                                                                             .characterEncoding: String.Encoding.utf8.rawValue],
                                                                   documentAttributes: nil)
                    commentLabel.attributedText = attributedString
                } catch {
                    print("Error decoding HTML: \(error)")
                    commentLabel.text = comment.content // 如果解析失败，使用原始文本
                }
            } else {
                commentLabel.text = comment.content // 如果内容为 nil，使用原始文本
            }
        }
    }
