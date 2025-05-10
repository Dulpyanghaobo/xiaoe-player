//
//  SubtitleView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//

import UIKit

class SubtitleView: UIView {
    private var aiCaptionsVOS: [AICaption]?
    private var currentTime: TimeInterval = 0
    var onHeightUpdated: ((CGFloat) -> Void)?
    private var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 5
        clipsToBounds = true

        addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
    }

    func updateSubtitles(with aiCaptionsVOS: [AICaption]) {
        self.aiCaptionsVOS = aiCaptionsVOS
    }

    func updateCurrentTime(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
        updateSubtitleText()
    }

    private func updateSubtitleText() {
        guard let aiCaptionsVOS = aiCaptionsVOS else { return }
        var visibleCaption: AICaption?
        for caption in aiCaptionsVOS {
            if let startMs = caption.startMs, let endMs = caption.endMs {
                if currentTime >= TimeInterval(startMs) / 1000 && currentTime <= TimeInterval(endMs) / 1000 {
                    visibleCaption = caption
                    break
                }
            }
        }
        subtitleLabel.text = visibleCaption?.text
        
        // 计算 label 所需的高度
        let maxWidth = UIScreen.main.bounds.width - 32 // Assuming the SubtitleView has 16 points padding on each side
        let requiredHeight = subtitleLabel.sizeThatFits(CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).height
        
        let totalHeight = requiredHeight + 16 // 添加上下内边距
        
        // 更新 SubtitleView 的高度约束
        self.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        
        // 强制更新布局
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
        
        // 调用回调，将高度传递出去
        onHeightUpdated?(totalHeight)
    }
}

