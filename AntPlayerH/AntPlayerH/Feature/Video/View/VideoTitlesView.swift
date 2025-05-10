//
//  VideoTitlesView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//
import UIKit

class VideoTitlesView: UIView {
    
    private var courseContentTitles: [CourseContentTitleVO] = [] // 存储字幕数据
    private var currentTime: TimeInterval = 0 // 当前播放时间
    private var titleViews: [UIView] = [] // 存储字幕视图
    private let stackView = UIStackView()
    private let progressBar = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .black.withAlphaComponent(0.3) // 示例背景色

        // 设置 StackView 的属性
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 0 // 没有额外的间距，分割线由子视图控制
        
        // 将 StackView 添加到主视图中
        self.addSubview(stackView)
        
        // 设置 StackView 的约束
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 使 stackView 充满整个父视图
        }
        
        // 设置进度条
        progressBar.backgroundColor = AppColors.themeColor // 进度条颜色
        self.insertSubview(progressBar, at: 0)
        progressBar.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0) // 初始宽度为 0
        }
    }

    // 更新字幕数据
    func updateTitles(_ titles: [CourseContentTitleVO]) {
        let courseContentTitles = [
            CourseContentTitleVO(text: "信号槽的概念", startMs: 0, endMs: 10800000, sort: 1, durationMs: 10800000),
            CourseContentTitleVO(text: "什么是信号槽", startMs: 10800000, endMs: 18000000, sort: 2, durationMs: 10800000),
            CourseContentTitleVO(text: "什么是信号", startMs: 18000000, endMs: 25200000, sort: 3, durationMs: 10800000),
            CourseContentTitleVO(text: "什么事槽函数", startMs: 25200000, endMs: 32400000, sort: 4, durationMs: 10800000),
            CourseContentTitleVO(text: "欢迎再次学习", startMs: 32400000, endMs: 41000000, sort: 5, durationMs: 10800000)
        ]

        self.courseContentTitles = courseContentTitles
        updateTitleViews()
    }

    // 更新当前播放时间
    func updateCurrentTime(_ currentTime: TimeInterval, duration: TimeInterval) {
        self.currentTime = currentTime
        // 计算进度条宽度比例
        let progressRatio = CGFloat(currentTime / duration)
        
        // 更新进度条的宽度
        progressBar.snp.updateConstraints { make in
            make.width.equalTo(progressRatio * screenWidth)
        }
        
        // 动画更新进度条
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

    private func updateTitleViews() {
        // 清除旧的子视图
        titleViews.forEach { $0.removeFromSuperview() }
        titleViews.removeAll()

        // 获取屏幕宽度
        let screenWidth = UIScreen.main.bounds.width
        
        // 获取视频总时长
        let totalDurationMs = courseContentTitles.last?.endMs ?? 1

        for (index, title) in courseContentTitles.enumerated() {
            guard let text = title.text, let durationMs = title.durationMs else { continue }

            // 计算宽度比例
            let widthRatio = CGFloat(durationMs) / CGFloat(totalDurationMs)
            let labelWidth = screenWidth * widthRatio
            
            // 创建标题的容器视图
            let containerView = UIView()

            // 创建并配置标题标签
            let titleLabel = UILabel()
            titleLabel.text = text
            titleLabel.textAlignment = .left
            titleLabel.backgroundColor = .clear
            titleLabel.numberOfLines = 1
            titleLabel.textColor = AppColors.primparyD7D7D7Color
            titleLabel.font = AppFonts.primary12Font
            containerView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(8) // 使 label 填充整个 containerView
            }
            // 添加容器视图到 StackView
            stackView.addArrangedSubview(containerView)
            titleViews.append(containerView)
            
            containerView.snp.makeConstraints { make in
                make.width.equalTo(labelWidth)
                make.height.equalToSuperview()
            }
            // 如果不是最后一个标题，添加分割线
            if index < courseContentTitles.count - 1 {
                let separatorView = UIView()
                stackView.addArrangedSubview(separatorView)
                separatorView.backgroundColor = .white // 分割线颜色
                separatorView.snp.makeConstraints { make in
                     make.width.equalTo(4) // 分割线宽度
                     make.height.equalToSuperview().multipliedBy(1) // 分割线高度为容器高度的 80%
                 }
            }
        }
    }
}
