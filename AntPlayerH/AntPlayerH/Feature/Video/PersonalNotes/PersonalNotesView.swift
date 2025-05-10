//
//  PersonalNotesView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//

import UIKit

class PersonalNotesView: PlayerDetailView {
    var personalNotes = [NoteRecord]() // 数据源
    var onTap: (() -> Void)?

    private let noteButton = PersonalNoteBottomView.init(frame: .zero)

    var onNewNoteAdded: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerCells()
        self.identifierCell = "NoteCell"
    }
    
    private func checkIfEmpty() {
        if personalNotes.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
        setupCommentInputView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func registerCells() {
        tableView.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
    }

    override func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let noteCell = cell as? NoteCell else { return }
        noteCell.configure(with: personalNotes[indexPath.row])
    }

    func updatePersonalNotes(_ notes: [NoteRecord]) {
        self.personalNotes = notes
        tableView.reloadData()
        checkIfEmpty()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let richEditor = PublishNoteView.init(frame: .zero)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = personalNotes[indexPath.row] // 假设你有一个 `comments` 数组
        let width = tableView.frame.width - 18 // 考虑左右的边距
        
        let commentAttributedText: NSAttributedString?
        if let htmlData = comment.content.data(using: .utf8) {
            commentAttributedText = try? NSAttributedString(data: htmlData,
                                                            options: [.documentType: NSAttributedString.DocumentType.html,
                                                                      .characterEncoding: String.Encoding.utf8.rawValue],
                                                            documentAttributes: nil)
        } else {
            commentAttributedText = NSAttributedString(string: comment.content)
        }
        let commentHeight = commentAttributedText?.heightWithConstrainedWidth(width: width) ?? 0

        return commentHeight + 16 + 16 + 16 // 额外的16是用于间距和填充的
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalNotes.count
    }

    func setupCommentInputView() {
        addSubview(noteButton)
        noteButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-16)
        }
//        addSubview(richEditor)
//        richEditor.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        noteButton.onTap = {
            self.onNewNoteAdded?()
        }
        // 调整 tableView 的底部内边距，以避免被 commentInputView 遮挡
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    @objc func addNoteButtonTapped() {

    }
}
