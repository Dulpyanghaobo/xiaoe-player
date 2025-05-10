//
//  PlayerBulletCommentsView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//

import UIKit
import SnapKit
import Kingfisher

class PlayerBulletCommentsView: PlayerDetailView {
    var bulletComments = [DanmakuResponse]() // 数据源
    private var isSettingVisible = false
    private let commentInputView = BulletCommentInputView()
    private var bulletSettingView: BulletSettingView?
    private var bulletSetttings: BulletSettings?

    var onNewBulletAdded: ((String, BulletSettings) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.identifierCell = "BulletCommentCell"
        setupCommentInputView()
        setupKeyboardObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCommentInputView() {
        addSubview(commentInputView)
        commentInputView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }

        commentInputView.onSend = { [weak self] text in
            self?.sendComment(text)
            self?.bulletSettingView?.removeFromSuperview()
            self?.commentInputView.textView.resignFirstResponder() // 隐藏键盘
            
        }
        commentInputView.onSettingButtonTapped = { [weak self] in
             self?.toggleBulletSettingView()
         }
        // 调整 tableView 的底部内边距，以避免被 commentInputView 遮挡
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 50, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets

            commentInputView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().inset(keyboardSize.height)
                make.height.equalTo(50)
            }
            
            // 确保当前编辑的 cell 可见
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: true)
            }
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        tableView.contentInset = contentInsets
        tableView.scrollIndicatorInsets = contentInsets
        self.commentInputView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(50)
        }

        self.layoutIfNeeded()
    }
    
    private func toggleBulletSettingView() {
        if isSettingVisible {
            hideBulletSettingView()
        } else {
            showBulletSettingView()
        }
        isSettingVisible.toggle()
    }
    
    private func showBulletSettingView() {
        
        if bulletSettingView == nil {
            bulletSettingView = BulletSettingView()
            bulletSettingView?.onSettingsChanged = { bulletSettings in
                self.bulletSetttings = bulletSettings
            }
            if let bulletSettingView = bulletSettingView {
                self.addSubview(bulletSettingView)
                
                bulletSettingView.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.height.equalTo(320) // 可以动态设置高度
                    make.bottom.equalToSuperview()
                }
            }
            UIView.animate(withDuration: 0.3) {
                guard let bulletSettingView = self.bulletSettingView else {
                    return
                }
                self.commentInputView.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.bottom.equalToSuperview().offset(-320)
                    make.height.equalTo(50)
                }
            }
        }
        

        self.layoutIfNeeded()
    }
    
    private func hideBulletSettingView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.commentInputView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.height.equalTo(50)
            }
            self.bulletSettingView?.removeFromSuperview()
            self.layoutIfNeeded()
        }) { _ in
        }
    }
    

    
    private func sendComment(_ content: String) {
        onNewBulletAdded?(content, self.bulletSetttings ?? BulletSettings(fontSize: .small, position: .top, fontColor: ._022d71))
    }
    
    override func registerCells() {
        tableView.register(BulletCommentCell.self, forCellReuseIdentifier: "BulletCommentCell")
    }

    override func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let bulletCommentCell = cell as? BulletCommentCell else { return }
        bulletCommentCell.configure(with: bulletComments[indexPath.row])
        bulletCommentCell.selectionStyle = .none
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bulletComments.count
    }

    override func defaultCellHeight() -> CGFloat {
        return UITableView.automaticDimension
    }

    func updateBulletComments(_ comments: [DanmakuResponse]) {
        self.bulletComments = comments
        tableView.reloadData()
    }
}

class BulletCommentCell: UITableViewCell {
    let avatarImageView = UIImageView()
    let titleLabel = UILabel()
    let timeLabel = UILabel()
    let videoTimeLabel = UILabel()
    let videoCurrentTimeIcon = UIImageView()
    let videoCurrentTimeLabel = UILabel()
    let commentLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // 添加子视图
        contentView.addSubview(avatarImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(videoTimeLabel)
        contentView.addSubview(videoCurrentTimeIcon)
        contentView.addSubview(videoCurrentTimeLabel)
        contentView.addSubview(commentLabel)

        // 设置布局
        avatarImageView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView.snp.right).offset(10)
            make.top.equalTo(avatarImageView)
            make.right.equalToSuperview().offset(-10)
        }

        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
        }

        videoTimeLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(avatarImageView)
        }

        videoCurrentTimeIcon.snp.makeConstraints { make in
            make.left.equalTo(timeLabel.snp.right).offset(5)
            make.centerY.equalTo(timeLabel)
            make.width.height.equalTo(15)
        }

        videoCurrentTimeLabel.snp.makeConstraints { make in
            make.left.equalTo(videoCurrentTimeIcon.snp.right).offset(5)
            make.centerY.equalTo(videoCurrentTimeIcon)
        }

        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(avatarImageView)
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 设置属性
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true

        titleLabel.font = AppFonts.primary12Font
        titleLabel.textColor = UIColor.init(hex: "343434 ")
        timeLabel.font = AppFonts.primaryDesc2Font
        timeLabel.textColor = UIColor.init(hex: "DCDCDC")
        videoTimeLabel.font = AppFonts.primaryDesc2Font
        videoTimeLabel.textColor = UIColor.init(hex: "DCDCDC")
        videoCurrentTimeLabel.font = UIFont.systemFont(ofSize: 12)
        videoCurrentTimeLabel.textColor = .gray
        commentLabel.numberOfLines = 0
        commentLabel.font = AppFonts.primaryDesc2Font
        commentLabel.textColor = UIColor.init(hex: "666666")
    }

    func configure(with comment: DanmakuResponse) {
        // 配置 UI 元素
        if let url = URL(string: comment.avatarVirtual) {
            // 使用一个库如 SDWebImage 来加载图片
            avatarImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_profile"))
        }
        titleLabel.text = comment.usernameVirtual
        timeLabel.text = comment.contentTime
        videoTimeLabel.text = "\(comment.videoTime)秒"
        videoCurrentTimeLabel.text = "\(comment.videoTime)秒"
        commentLabel.text = comment.content
        commentLabel.textColor = UIColor.init(hex: comment.fontColor ?? "#666666")
    }
}
