//
//  CourseInfoCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import UIKit
import Kingfisher
import SnapKit
import AHDownloadButton

class CourseInfoCell: UITableViewCell {

    // 定义视图元素
    let cellImageView = UIImageView()
    let titleLabel = UILabel()
    let videoSizeLabel = UILabel()
    let videoInfoLabel = UILabel()
    let downloadButton = AHDownloadButton()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置视图元素
    private func setupViews() {
        // 添加视图元素到contentView
        contentView.addSubview(cellImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(videoSizeLabel)
        contentView.addSubview(videoInfoLabel)
        contentView.addSubview(downloadButton)

        // 配置视图元素属性
        cellImageView.contentMode = .scaleAspectFill
        cellImageView.clipsToBounds = true
        titleLabel.font = AppFonts.primary14Font
        titleLabel.textColor = AppColors.primaryTitle2Color
        titleLabel.numberOfLines = 2
        videoSizeLabel.font = AppFonts.primaryDesc2Font
        videoSizeLabel.textColor = AppColors.primaryDescColor
        videoInfoLabel.font = AppFonts.primaryDesc2Font
        videoInfoLabel.textColor = AppColors.primaryDescColor
    }

    // 设置布局约束
    private func setupConstraints() {
        cellImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(cellImageView.snp.trailing).offset(16)
            make.top.equalTo(cellImageView)
            make.trailing.equalToSuperview().offset(-16)
        }

        videoSizeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
        }

        videoInfoLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(videoSizeLabel.snp.bottom).offset(2)
        }

        downloadButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(32)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    // 配置单元格内容
    func configure(with course: CourseInfo) {
        titleLabel.text = course.courseName
        videoSizeLabel.text = course.videoSizeStr
        // 格式化时间并设置标签文本
        videoInfoLabel.text = Double((course.whenLong ?? 0) / 1000).formattedTime()
        let placeholderImage = UIImage(named: "course_default_image")
        if let url = URL(string: course.coverUrl ?? "") {
            cellImageView.kf.setImage(with: url, placeholder: placeholderImage)
        } else {
            cellImageView.image = placeholderImage
        }

        // 假设我们根据某个条件来判断是否已下载，这里暂时用videoSize > 0来模拟
        let isDownloaded = course.courseType == 0
        downloadButton.delegate = self
        downloadButton.downloadedButtonTitle = "已缓存"
//        downloadButton.startDownloadButtonImage = "xiazai_icon"
        
//        if isDownloaded {
//            downloadButton.setTitle("已缓存", for: .normal)
//            downloadButton.titleLabel?.font = AppFonts.primaryDescFont
//            downloadButton.setTitleColor(AppColors.themeColor, for: .normal)
//
//            downloadButton.setImage(nil, for: .normal)
//        } else {
//            downloadButton.setTitle(nil, for: .normal)
//            downloadButton.setImage(UIImage(named: "xiazai_icon"), for: .normal)
//        }
    }
}
extension CourseInfoCell: AHDownloadButtonDelegate {
    func downloadButton(_ downloadButton: AHDownloadButton, tappedWithState state: AHDownloadButton.State) {
        switch state {
        case .startDownload:

            // set the download progress to 0
            downloadButton.progress = 0

            // change state to pending and wait for download to start
            downloadButton.state = .pending

            // initiate download and update state to .downloading
//            startDownloadingFile()

        case .pending:

            // button tapped while in pending state
            break

        case .downloading:

            // button tapped while in downloading state - stop downloading
            downloadButton.progress = 0
            downloadButton.state = .startDownload

        case .downloaded: break

            // file is downloaded and can be opened
//            openDownloadedFile()

        }
    }
}
