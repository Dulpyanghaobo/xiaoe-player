//
//  CoursePlayerDetailCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/30/24.
//

import UIKit

class CoursePlayerDetailCell: UITableViewCell {

    // UI 元素
    private let playButton = UIButton()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let learnedTimeLabel = UILabel()
    private let learningButton = UIButton()
    
    // 当前课程是否正在学习
    var isLearning: Bool = false {
        didSet {
            updateUIForLearningState()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // 播放按钮配置
        playButton.setImage(UIImage(systemName: "play.circle")?.withTintColor(AppColors.primaryTitle2Color, renderingMode: .alwaysOriginal), for: .normal)
        contentView.addSubview(playButton)
        
        // 标题标签配置
        titleLabel.font = AppFonts.primary14Font
        titleLabel.textColor = AppColors.primary222A30Color
        contentView.addSubview(titleLabel)
        // 描述标签配置
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textColor = AppColors.primary9B9D9FColor
        contentView.addSubview(descLabel)
        // 学习时间标签配置
        learnedTimeLabel.font = UIFont.systemFont(ofSize: 12)
        learnedTimeLabel.textColor = AppColors.primary9B9D9FColor
        contentView.addSubview(learnedTimeLabel)
        // 正在学习按钮配置
        learningButton.setTitle("正在学习", for: .normal)
        learningButton.setTitleColor(.white, for: .normal)
        learningButton.titleLabel?.font = AppFonts.primaryDesc2Font
        learningButton.backgroundColor = AppColors.themeColor
        learningButton.layer.cornerRadius = 9
        learningButton.isHidden = true
        contentView.addSubview(learningButton)
        // 使用 SnapKit 进行布局
        playButton.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).offset(16)
            make.top.equalTo(contentView).offset(8)
            make.trailing.equalTo(contentView.snp.centerX).offset(56)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalTo(contentView).offset(-2)
        }
        
        learnedTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(descLabel.snp.trailing).offset(8)
            make.centerY.equalTo(descLabel)
        }
        
        learningButton.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-16)
            make.centerY.equalTo(contentView)
            make.size.equalTo(CGSize.init(width: 52, height: 18))
        }
    }
    
    func configure(with courseInfo: CourseInfo, selectCousreInfo: CourseInfo?) {
        titleLabel.text = courseInfo.courseName
        descLabel.text = Double((courseInfo.whenLong ?? 0) / 1000).formattedTime()
        guard let playRate = courseInfo.playRate else { return }
        if playRate != 0 {
            learnedTimeLabel.text = "已学习\(playRate)%"
        }
        
        // 高亮显示当前选中的课程
        if selectCousreInfo?.courseInfoId == courseInfo.courseInfoId {
            isLearning = true
            updateUIForLearningState() // 恢复默认颜色
            
        } else {
            isLearning = false
            updateUIForLearningState() // 恢复默认颜色
        }
    }
    
    private func updateUIForLearningState() {
        if isLearning {
            titleLabel.textColor = AppColors.themeColor
            descLabel.textColor = AppColors.themeColor
            learnedTimeLabel.textColor = AppColors.themeColor
            playButton.setImage(UIImage(systemName: "play.circle")?.withTintColor(AppColors.themeColor, renderingMode: .alwaysOriginal), for: .normal)
            learningButton.isHidden = false
        } else {
            titleLabel.textColor = AppColors.primary222A30Color
            descLabel.textColor = AppColors.primary9B9D9FColor
            learnedTimeLabel.textColor = AppColors.primary9B9D9FColor
            learningButton.isHidden = true
            playButton.setImage(UIImage(systemName: "play.circle")?.withTintColor(AppColors.primaryTitle2Color, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
}
