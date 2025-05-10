//
//  CommentCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/29/24.
//

import UIKit
import SnapKit
import Kingfisher

class CommentCell: UITableViewCell {
    
    private let profileImageView = UIImageView()
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
        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(commentLabel)

        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(28)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(2)
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

        profileImageView.layer.cornerRadius = 14
        profileImageView.clipsToBounds = true

        titleLabel.font = AppFonts.primary14Font
        titleLabel.textColor = AppColors.primary343434BackColor
        descLabel.font = AppFonts.primary12Font
        descLabel.textColor = AppColors.primaryDCDCDCBackColor
        commentLabel.font = AppFonts.primary14Font
        commentLabel.textColor = AppColors.primaryTitle2Color
        commentLabel.numberOfLines = 0
    }

    func configure(with comment: CommentRecord) {
        titleLabel.text = comment.userName
        descLabel.text = comment.contentTime
        commentLabel.text = comment.content
        if let imageUrl = URL(string: comment.avatar ?? "") {
             profileImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "course_default_image"))
         }
    }
}
