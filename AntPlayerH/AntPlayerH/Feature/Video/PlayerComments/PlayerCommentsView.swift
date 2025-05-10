//
//  PlayerCommentsView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/25/24.
//

import UIKit

class PlayerCommentsView: PlayerDetailView {
    var comments = [CommentRecord]() // 数据源
    private var isLoading = false // 标记是否正在加载
    private let commentInputView = CommentInputView()

    var onNewCommentAdded: ((String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        identifierCell = "CommentCell"
        registerCells()
        self.tableView.backgroundColor = .white
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        setupCommentInputView()
        setupKeyboardObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func registerCells() {
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
    }

    override func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        guard let commentCell = cell as? CommentCell else { return }
        commentCell.configure(with: comments[indexPath.row])
    }

    func updateComments(_ comments: [CommentRecord]) {
        self.comments = comments
        tableView.reloadData()
        checkIfEmpty()
    }
    
    private func checkIfEmpty() {
        if comments.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let comment = comments[indexPath.row]
        let cell = CommentCell(style: .default, reuseIdentifier: "CommentCell")
        cell.configure(with: comment)

        // 计算内容的大小
        let targetSize = CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let size = cell.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        return size.height + 34
    }

    @objc private func refreshComments() {
        // 调用接口刷新数据
        loadComments(refresh: true)
    }
    
    func setupCommentInputView() {
        addSubview(commentInputView)
        commentInputView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(50)
        }

        commentInputView.onSend = { [weak self] text in
            self?.sendComment(text)
            self?.commentInputView.textView.resignFirstResponder() // 隐藏键盘
            
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

        commentInputView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(50)
        }
    }
    private func sendComment(_ content: String) {
        onNewCommentAdded?(content)
    }

    private func loadComments(refresh: Bool) {
        guard !isLoading else { return }
        isLoading = true
    }
}
