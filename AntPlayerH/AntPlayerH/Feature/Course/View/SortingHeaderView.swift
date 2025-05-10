//
//  SortingHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import UIKit
import SnapKit

enum SortOrder {
    case ascending
    case descending
    
    var description: String {
        switch self {
        case .ascending:
            return "按升序排序"
        case .descending:
            return "按降序排序"
        }
    }
    
    var orderString: String {
        switch self {
        case .ascending:
            return "ASC"
        case .descending:
            return "DESC"
        }
    }
}

class SortingHeaderView: UIView {
    
    private var currentSortOrder: SortOrder = .ascending // 默认升序
    private var onSortOrderChanged: (SortOrder) -> Void

    private var popup: PopupView!
    let sortLabel: UILabel = {
        let label = UILabel()
        label.text = SortOrder.ascending.description // 默认升序
        label.textColor = AppColors.primaryDescColor
        label.font = AppFonts.primary12Font
        return label
    }()
    
    let sortButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("排序", for: .normal)
        button.setTitleColor(AppColors.primaryDescColor, for: .normal)
        button.titleLabel?.font = AppFonts.primary12Font
        return button
    }()
    
    private var sortOrder: String = "ASC" // 默认升序
    
    init(currentSortOrder: SortOrder, onSortOrderChanged: @escaping (SortOrder) -> Void, frame: CGRect) {
        self.currentSortOrder = currentSortOrder
        self.onSortOrderChanged = onSortOrderChanged
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(sortLabel)
        addSubview(sortButton)
        
        sortLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        
        sortButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        sortButton.addTarget(self, action: #selector(showSortPopup), for: .touchUpInside)
    }
    
    @objc private func showSortPopup() {
        let sortView = SortAlertView(currentSortOrder: currentSortOrder) { [weak self] order in
            self?.updateSortOrder(order)
            self?.onSortOrderChanged(order)
            self?.popup.dismiss()
        }
        self.popup = PopupView(contentView: sortView, popupType: .bottom, animationType: .fade)
        PopupManager.shared.showPopup(popup)
    }
    
    private func hidenSortPop() {
        
    }
    
    private func updateSortOrder(_ order: SortOrder) {
        currentSortOrder = order
        sortLabel.text = currentSortOrder.description
        sortLabel.textColor = (currentSortOrder == .ascending) ? .blue : AppColors.primaryDescColor
    }
}
