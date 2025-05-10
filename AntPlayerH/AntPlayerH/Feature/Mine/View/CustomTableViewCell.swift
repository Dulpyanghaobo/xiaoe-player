//
//  CustomTableViewCell.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
@available(iOS 16.0, *)
class CustomTableViewCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        iconImageView.contentMode = .scaleAspectFit
        contentView.addSubview(iconImageView)
        titleLabel.font = AppFonts.primary14Font
        contentView.addSubview(titleLabel)
        titleLabel.textColor = AppColors.primaryTitleColor
        arrowImageView.image = UIImage(named: "fanhui_icon")
        contentView.addSubview(arrowImageView)

        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        arrowImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    func configure(iconName: String, title: String) {
        iconImageView.image = UIImage(named: iconName)
        titleLabel.text = title
    }
}
