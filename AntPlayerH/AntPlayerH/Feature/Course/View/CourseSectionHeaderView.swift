//
//  CourseSectionHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//
import UIKit
import SnapKit

class CourseSectionHeaderView: UIView {

    let folderImageView = UIImageView()
    let titleLabel = UILabel()
    let videoCountLabel = UILabel()
    let expandButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        // 配置视图元素属性
        folderImageView.image = UIImage(named: "wenjianjia_icon")
        folderImageView.contentMode = .scaleAspectFit

        titleLabel.font = AppFonts.primaryTitleFont
        titleLabel.textColor = AppColors.primaryTitleColor
        
        videoCountLabel.font = AppFonts.primaryDesc2Font
        videoCountLabel.textColor = AppColors.primaryDescColor

        expandButton.setImage(UIImage(named: "zhankai_icon"), for: .normal)

        // 添加视图元素到self
        addSubview(folderImageView)
        addSubview(titleLabel)
        addSubview(videoCountLabel)
        addSubview(expandButton)
    }

    private func setupConstraints() {
        folderImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(folderImageView.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        videoCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }

        expandButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    func configure(title: String, videoCount: Int, isExpanded: Bool) {
        titleLabel.text = title
        videoCountLabel.text = "\(videoCount)部视频"
        let buttonImageName = isExpanded ? "zhankai_icon" : "zhankai_icon_02"
        expandButton.setImage(UIImage(named: buttonImageName), for: .normal)
    }
}
