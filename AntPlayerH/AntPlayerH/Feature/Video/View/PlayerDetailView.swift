//
//  PlayerDetailView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/29/24.
//

import UIKit
import SnapKit
import JXSegmentedView

enum VideoSubViewType: CaseIterable {
    case courseDetail
    case comments
    case personalNotes
    case aiNotes
    case bulletComments
}

class PlayerDetailView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyView = EmptyView()
    var identifierCell: String = "Cell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTableView()
        setupEmptyView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        self.tableView.backgroundColor = .white
        self.tableView.separatorStyle = .none
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        registerCells()
    }
    
    private func setupEmptyView() {
        addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyView.isHidden = true
        emptyView.tableView = self.tableView
    }

    func showEmptyView() {
        emptyView.isHidden = false
    }

    func hideEmptyView() {
        emptyView.isHidden = true
    }

    // 默认高度，子类可以重写
    func defaultCellHeight() -> CGFloat {
        return 48
    }

    func registerCells() {
        // 子类需要重写并注册具体的cell
    }

    func configure(cell: UITableViewCell, at indexPath: IndexPath) {
        // 子类需要重写并配置具体的cell
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0 // 子类需要重写
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierCell, for: indexPath)
        configure(cell: cell, at: indexPath)
        return cell
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultCellHeight()
    }

}
extension PlayerDetailView: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return self
    }
}
