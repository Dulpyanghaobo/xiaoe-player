//
//  CourseTableHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/30/24.
//

import UIKit
import SnapKit

@available(iOS 16.0, *)
class CoursePlayerTableHeaderView: UIView {
    private let titleLabel = UILabel()
    private let iconImageView = UIImageView(image: UIImage(systemName: "person.circle"))
    private let numsLabel = UILabel()
    private let playIconImageView = UIImageView(image: UIImage(systemName: "play.circle"))
    private let playNumsLabel = UILabel()
    private let descLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white

        
        // 标题标签配置
        titleLabel.font = AppFonts.primary14Font
        titleLabel.textColor = AppColors.primary343434BackColor
        addSubview(titleLabel)
        
        // 描述标签配置
        descLabel.font = AppFonts.primary12Font
        descLabel.textColor = AppColors.primaryCDCDCDBackColor
        addSubview(descLabel)
        
        // 学习时间标签配置
        numsLabel.font = AppFonts.primary12Font
        numsLabel.textColor = AppColors.primaryCDCDCDBackColor
        iconImageView.tintColor = AppColors.primaryCDCDCDBackColor
        addSubview(iconImageView)
        
        numsLabel.font =  AppFonts.primary12Font
        numsLabel.textColor = AppColors.primaryCDCDCDBackColor
        addSubview(numsLabel)
        
        playIconImageView.tintColor = AppColors.primaryCDCDCDBackColor
        addSubview(playIconImageView)
        
        playNumsLabel.font =  AppFonts.primary12Font
        playNumsLabel.textColor = AppColors.primaryCDCDCDBackColor
        addSubview(playNumsLabel)
        
        descLabel.font =  AppFonts.primary12Font
        descLabel.textColor = AppColors.primaryCDCDCDBackColor
        addSubview(descLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(16)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.width.height.equalTo(12)
        }
        
        numsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(iconImageView.snp.trailing).offset(2)
        }
        
        playIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(iconImageView)
            make.leading.equalTo(numsLabel.snp.trailing).offset(16)
            make.width.height.equalTo(12)
        }
        
        playNumsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playIconImageView)
            make.leading.equalTo(playIconImageView.snp.trailing).offset(2)
        }
        
        descLabel.snp.makeConstraints { make in
            make.centerY.equalTo(playIconImageView)
            make.leading.equalTo(playNumsLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-2)

        }
    }
    
    func configure(with playInfoResponse: CourseDirectoryPlayInfoResponse,onlineCoursesResponse: OnlineCoursesResponse) {
        titleLabel.text = onlineCoursesResponse.catalogName
        numsLabel.text = "\(playInfoResponse.studentNumbs)人"
        if let playNumbs = playInfoResponse.playNumbs {
            playNumsLabel.text = "\(playNumbs)次播放"
        } else {
            playNumsLabel.text = "0次播放"
        }
        descLabel.text = playInfoResponse.warnNotice
    }
}
