//
//  SoftwareSettingsViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit

class SoftwareSettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    let sections: [String] = ["播放设置", "弹幕设置", "其他设置"]
    let items: [[(title: String, desc: String, key: String)]] = [
        [("视频自动播放", "自动播放视频", "autoPlay"),
         ("视频自动全屏播放", "自动全屏播放视频", "autoFullScreenPlay")],
        [("记忆弹窗开关状态", "记住弹窗的开关状态", "rememberPopupState"),
         ("弹幕便捷操作功能", "启用便捷操作弹幕", "bulletScreenQuickOperation"),
         ("弹幕使用推荐字体", "使用推荐的弹幕字体", "bulletScreenRecommendedFont")],
        [("启动重力感应旋屏", "启用重力感应旋转屏幕", "enableGravityRotation"),
         ("退出播放时自动小窗播放", "退出播放时自动小窗播放", "autoPipOnExit")]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "播放设置"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(navigationFullHeight)
            make.right.left.bottom.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
        // 设置 Section 之间的间距
        tableView.sectionFooterHeight = 8
        tableView.sectionHeaderHeight = 0
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsTableViewCell
        cell.selectionStyle = .none
        let item = items[indexPath.section][indexPath.row]
        cell.titleLabel.text = item.title
        cell.descLabel.text = item.desc
        cell.switchControl.isOn = VideoPlayerConfig.shared.getBool(forKey: item.key)
        cell.switchControl.tag = indexPath.section * 100 + indexPath.row
        cell.switchControl.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        let section = sender.tag / 100
        let row = sender.tag % 100
        let key = items[section][row].key
        VideoPlayerConfig.shared.setBool(sender.isOn, forKey: key)
    }
}

class SettingsTableViewCell: UITableViewCell {
    
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let switchControl = UISwitch()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = AppColors.primaryTitleColor
        titleLabel.font = AppFonts.primaryTitleFont
        descLabel.textColor = AppColors.primpary949494Color
        descLabel.font = AppFonts.primaryDesc2Font
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
        ])
        // 设置 Switch 背景颜色和大小
          switchControl.onTintColor = AppColors.themeColor
          switchControl.transform = CGAffineTransform(scaleX: 28/51, y: 15/31) // UISwitch 默认大小是 51x31
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VideoPlayerConfig {
    
    static let shared = VideoPlayerConfig()
    
    private let defaults = UserDefaults.standard
    
    func getBool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}
