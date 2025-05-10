//
//  DeviceTableViewCell.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit
import SnapKit

class DeviceTableViewCell: UITableViewCell {
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let localLabel = UILabel()
    private let deleteButton = UIButton(type: .system)

    var deleteButtonAction: (() -> Void)?

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
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = AppColors.primaryTitleColor
        contentView.addSubview(titleLabel)
        
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = AppColors.primaryDescColor
        contentView.addSubview(descLabel)
        
        localLabel.font = UIFont.systemFont(ofSize: 12)
        localLabel.textColor = AppColors.primaryDescColor
        contentView.addSubview(localLabel)
        
        deleteButton.setTitle("删除设备", for: .normal)
        deleteButton.setTitleColor(AppColors.themeColor, for: .normal)
        deleteButton.backgroundColor = AppColors.themeColor.withAlphaComponent(0.33)
        deleteButton.layer.cornerRadius = 16

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        contentView.addSubview(deleteButton)
        
        setupConstraints()
    }

    private func setupConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(58)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.top.equalToSuperview().offset(10)
            make.right.equalTo(deleteButton.snp.left).offset(-10)
        }
        
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.right.equalTo(deleteButton.snp.left).offset(-10)
        }
        
        localLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(descLabel.snp.bottom).offset(5)
            make.right.equalTo(deleteButton.snp.left).offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize.init(width: 80, height: 32))
        }
    }

    @objc private func deleteButtonTapped() {
        deleteButtonAction?()
    }

    func configure(with device: DeviceInfo) {
        iconImageView.image = UIImage(named: "iphone_image") // 替换为实际的设备图标
        guard let lasterLoginTime = device.lasterLoginTime, let deviceModelName = device.deviceModelName, let lasterLoginLocation = device.lasterLoginLocation, let lasterLoginIp = device.lasterLoginIp else { return }
        titleLabel.text = device.deviceName
        descLabel.text = "\(lasterLoginTime) · \(deviceModelName)"
        localLabel.text = "\(lasterLoginLocation)（\(lasterLoginIp)）"
    }
}
