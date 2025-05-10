//
//  CourseBottomCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import UIKit

struct SimpleCourseModel {
    let title: String
    let desc: String
    let imageName: String
}

class CourseBottomCell: UICollectionViewCell {
    
    // MARK: - Properties
    private let customImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.primaryTitleFont
        label.textColor = AppColors.primaryTitleColor
        return label
    }()
    
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.primary12Font
        label.textColor = AppColors.primaryDescColor
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        contentView.addSubview(customImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        
        // 设置布局约束
        customImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(customImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.trailing.equalTo(titleLabel.snp.trailing)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    // MARK: - Configuration
    func configure(simpleCourseModel: SimpleCourseModel) {
        customImageView.image = UIImage(named: simpleCourseModel.imageName)
        titleLabel.text = simpleCourseModel.title
        descLabel.text = simpleCourseModel.desc
    }
}
