//
//  PlayerAINotesView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//

import UIKit
import JXSegmentedView

class PlayerAINotesView: UIView {
    var aiNotes: [AINoteResponse] = [] // 数据源
    var textView: UITextView = UITextView()
    var headerView: UIView = UIView()
    var titleLabel: UILabel = UILabel()
    var checkAiNote: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHeaderView()
        setupTextView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHeaderView() {
        // 设置 headerView
        self.backgroundColor = .white
        headerView.backgroundColor = .white
        self.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(50) // 设置标题高度
        }

        // 设置标题
        titleLabel.text = "AI识别记录"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
    }

    private func setupTextView() {
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.font = UIFont.systemFont(ofSize: 14) // 修改字体大小
        textView.textColor = .gray // 修改字体颜色为灰色
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom) // TextView的顶部与headerView的底部对齐
        }

        // 添加点击手势识别器
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        textView.addGestureRecognizer(tapGesture)
    }

    func updateAINotes(_ notes: [AINoteResponse]) {
        self.aiNotes = notes
        assembleText()
    }

    private func assembleText() {
        let attributedText = NSMutableAttributedString()

        for note in aiNotes {
            let words = note.finalSentence
            let attributedWordString = NSMutableAttributedString(string: words ?? "")
            attributedWordString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: note.finalSentence?.count ?? 1))
//            attributedWordString.addAttribute(NSAttributedString.Key.link, value: note.startMs ?? 1, range: NSRange(location: 0, length: note.finalSentence?.count ?? 1))
            attributedText.append(attributedWordString)
        }

        textView.attributedText = attributedText
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: textView)
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        if characterIndex < textView.textStorage.length {
            // 获取点击位置的字符范围的属性字典
            let attributes = textView.attributedText.attributes(at: characterIndex, effectiveRange: nil)
            
            // 检查是否有 NSAttributedString.Key.link 属性
            if let linkValue = attributes[NSAttributedString.Key.link] {
                print("Link value: \(linkValue)")
                // 在这里处理 linkValue
            }
        }

    }
    
    func currentTimeWorkSelect(with currentTime: TimeInterval) {
        let attributedText = NSMutableAttributedString()
        
        for note in aiNotes {
            let attributedWordString = NSMutableAttributedString(string: note.finalSentence ?? "")
            
            if let startMs = note.startMs, let endMs = note.endMs {
                if Int(currentTime * 1000) >= startMs && Int(currentTime * 1000) <= endMs {
                    // 高亮当前时间戳对应的文字
                    attributedWordString.addAttribute(.foregroundColor, value: AppColors.themeColor, range: NSRange(location: 0, length: note.finalSentence?.count ?? 1))
                } else {
                    // 非高亮的文字使用默认颜色
                    attributedWordString.addAttribute(.foregroundColor, value: UIColor.gray, range: NSRange(location: 0, length: note.finalSentence?.count ?? 1))
                }
                
                attributedText.append(attributedWordString)
            }
            
            textView.attributedText = attributedText
        }
    }
}


extension PlayerAINotesView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
