//
//  VideoControlsView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/11/24.
//

import UIKit
import IJKMediaFramework

class VideoControlCell: UITableViewCell {
    // 在这里添加自定义的视图和属性
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview()
        }
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    func configure(with title: String) {
        titleLabel.text = title
    }
}

enum VideoControlsType: Int, CaseIterable {
    case none
    case speed
    case aspectRatio
    case tracks
    case subtitle
    case aiCaption
}

protocol VideoControlsViewDelegate: AnyObject {
    func didSelectSpeed(speedModel: SpeedModel)
    func didSelectAspectRatio(aspectRatio: IJKMPMovieScalingMode)
    func didSelectTrack(track: String)
    func didSelectSubtitle(subtitle: String)
    func didSelectAiCaption(isOpen: Bool)

}

class VideoControlsView: UIView {
    weak var delegate: VideoControlsViewDelegate?
    var controlsTypes: VideoControlsType = .none
    private var tableView: UITableView!
    private var speedModels: [SpeedModel] = []
    private var aspectRatioModels: [AspectRatioModel] = []
    private var aiCaptionModels: [AiCaptionModel] = []
    var selectedCousreInfoId: Int = 1
    private var cousreInfos: [CourseInfo] = []
    
    var onCellSelected: ((IndexPath) -> Void)?
    var onTrackSelected: ((CourseInfo) -> Void)?
    var onCaptionsSelected: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSpeedModels()
        setupAspectRatioModels()
        setupAiCaptionModels()
        setupTableView()
    }
    
    init(frame: CGRect, cousreInfos: [CourseInfo], selectedCousreInfoId: Int, controlsTypes: VideoControlsType) {
        super.init(frame: frame)
        self.cousreInfos = cousreInfos
        self.controlsTypes = controlsTypes
        self.selectedCousreInfoId = selectedCousreInfoId
        setupSpeedModels()
        setupAspectRatioModels()
        setupAiCaptionModels()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSpeedModels()
        setupAspectRatioModels()
        setupTableView()
    }
    
    private func setupSpeedModels() {
        speedModels = [
            SpeedModel(name: "2.0x", speed: 2.0),
            SpeedModel(name: "1.75x", speed: 1.75),
            SpeedModel(name: "1.5x", speed: 1.5),
            SpeedModel(name: "1.25x", speed: 1.25),
            SpeedModel(name: "1.0x", speed: 1.0),
            SpeedModel(name: "0.75x", speed: 0.75),
            SpeedModel(name: "0.5x", speed: 0.5)
        ]
    }

    private func setupAspectRatioModels() {
        aspectRatioModels = [
            AspectRatioModel(name: "拉升", ratio: .fill),
            AspectRatioModel(name: "全屏", ratio: .aspectFill),
            AspectRatioModel(name: "4:3", ratio: .aspectFit),
            AspectRatioModel(name: "16:9", ratio: .none)
        ]
    }
    
    private func setupAiCaptionModels() {
        aiCaptionModels = [
            AiCaptionModel(name: "中文（AI生成）", isOpen: true),
            AiCaptionModel(name: "关闭", isOpen: false)
        ]
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let totalHeight = tableView.contentSize.height
        let viewHeight = bounds.height

        // 计算并设置 contentOffset 以确保居中
        if totalHeight < viewHeight {
            tableView.contentOffset = CGPoint(x: 0, y: (viewHeight - totalHeight) / 4)
        } else {
            tableView.contentOffset = CGPoint.zero
        }
        
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: bounds, style: .plain)
        self.backgroundColor = .clear
        self.tableView.backgroundColor = .black.withAlphaComponent(0.5)
        tableView.separatorStyle = .none
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.register(VideoTrackCell.self, forCellReuseIdentifier: "VideoTrackCell")
        tableView.register(VideoControlCell.self, forCellReuseIdentifier: "VideoControlCell")
        tableView.dataSource = self
        tableView.delegate = self
        let inset = (bounds.height - (CGFloat(self.tableView.numberOfSections) * self.tableView.rowHeight)) / 2
        tableView.contentInset = UIEdgeInsets(top: max(inset, 0), left: 0, bottom: 0, right: 0)
        
    }
    
    func reloadData() {
        self.tableView.reloadData()
    }
}


extension VideoControlsView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.controlsTypes {
        case .speed:
            return speedModels.count
        case .aspectRatio:
            return aspectRatioModels.count // 假设有4个视频比例选项
        case .tracks:
            return self.cousreInfos.count // 假设有5个轨道选项
        case .subtitle:
            return 3 // 假设有3个字幕选项
        case .none:
            return 0
        case .aiCaption:
            return self.aiCaptionModels.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch self.controlsTypes {
        case .speed:
            return 45
        case .aspectRatio:
            return 45
        case .tracks:
            return 64
        case .subtitle:
            return 45
        case .none:
            return 45
        case .aiCaption:
            return 45
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.controlsTypes {
        case .speed:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControlCell") as! VideoControlCell
            let speedModel = speedModels[indexPath.row]
            cell.titleLabel.text = speedModel.name
            return cell
        case .aspectRatio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControlCell") as! VideoControlCell
            let aspectRatioModel = aspectRatioModels[indexPath.row]
            cell.titleLabel.text = aspectRatioModel.name
            return cell
        case .tracks:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTrackCell", for: indexPath) as! VideoTrackCell
            let courseInfo = cousreInfos[indexPath.row] // 假设 courses 是一个 CourseInfo 数组
            cell.configure(with: courseInfo, selectedCourseID: self.selectedCousreInfoId)
            return cell
        case .subtitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControlCell") as! VideoControlCell
            cell.textLabel?.text = "字幕类型"
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControlCell") as! VideoControlCell
            return cell
        case .aiCaption:
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoControlCell") as! VideoControlCell
            let aiCaptionModel = aiCaptionModels[indexPath.row]
            cell.titleLabel.text = aiCaptionModel.name
                
            return cell
        }
    }
}

extension VideoControlsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.controlsTypes {
        case .speed:
            let selectedSpeedModel = speedModels[indexPath.row]
            self.delegate?.didSelectSpeed(speedModel: selectedSpeedModel)
        case .aspectRatio:
            let aspectRatioModel = aspectRatioModels[indexPath.row]
            self.delegate?.didSelectAspectRatio(aspectRatio: aspectRatioModel.ratio)
        case .tracks:
            delegate?.didSelectTrack(track: "Track \(indexPath.row + 1)")
            self.onTrackSelected?(cousreInfos[indexPath.row])
        case .subtitle:
            delegate?.didSelectSubtitle(subtitle: "Subtitle \(indexPath.row + 1)")
        case .none:
            break
        case .aiCaption:
            let aiCaptionModel = aiCaptionModels[indexPath.row]
            self.onCaptionsSelected?(aiCaptionModel.isOpen)
            delegate?.didSelectAiCaption(isOpen: aiCaptionModel.isOpen)
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            self.onCellSelected?(indexPath)
        }
    }

}

struct SpeedModel {
    let name: String
    let speed: Double
}

struct AiCaptionModel {
    let name: String
    let isOpen: Bool
}
// 定义视频比例模型
struct AspectRatioModel {
    let name: String
    let ratio: IJKMPMovieScalingMode
}
class VideoTrackCell: UITableViewCell {
    
    // UI元素
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let videoInfoLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // 设置封面图片
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 4
        coverImageView.clipsToBounds = true
        contentView.addSubview(coverImageView)
        
        // 设置标题标签
        titleLabel.font = AppFonts.primary12Font
        titleLabel.numberOfLines = 2
        titleLabel.textColor = AppColors.primparyCCCCCCColor
        contentView.addSubview(titleLabel)
        
        // 设置视频信息标签
        videoInfoLabel.font = UIFont.systemFont(ofSize: 14)
        videoInfoLabel.textColor = AppColors.primparyCCCCCCColor
        contentView.addSubview(videoInfoLabel)
        
        // 布局使用 SnapKit
        coverImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(96)
            make.height.equalTo(52)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.top.equalTo(contentView.snp.top).offset(0)
        }
        
        videoInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }
    }
    
    // 配置方法
    func configure(with courseInfo: CourseInfo, selectedCourseID: Int?) {
        if let urlString = courseInfo.coverUrl, let url = URL(string: urlString) {
            // 这里可以使用第三方库加载图片,例如 SDWebImage
            coverImageView.kf.setImage(with: url)
        }
        
        titleLabel.text = courseInfo.courseName ?? "课程名称"
        
        if let whenLong = courseInfo.whenLong {
            videoInfoLabel.text = String(format: "%.1f秒", Double(whenLong) / 1000) // 格式化时长
        } else {
            videoInfoLabel.text = "时长未知"
        }
        
        // 高亮显示当前选中的视频
        if courseInfo.courseInfoId == selectedCourseID {
            titleLabel.textColor = AppColors.themeColor // 更改标题颜色
            videoInfoLabel.textColor = AppColors.themeColor // 更改信息颜色
        } else {
            titleLabel.textColor = AppColors.primparyCCCCCCColor // 恢复默认颜色
            videoInfoLabel.textColor = AppColors.primparyCCCCCCColor // 恢复默认颜色
        }
    }
}
