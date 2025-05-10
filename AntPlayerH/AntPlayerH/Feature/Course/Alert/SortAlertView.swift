//
//  SortAlertView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/7/24.
//

import UIKit
import SnapKit

class SortAlertView: UIView {
    
    private let ascendingButton = UIButton(type: .custom)
    private let descendingButton = UIButton(type: .custom)
    private let buttonStackView = UIStackView()
    
    private var currentSortOrder: SortOrder
    private var onSortOrderChanged: (SortOrder) -> Void
    
    init(currentSortOrder: SortOrder, onSortOrderChanged: @escaping (SortOrder) -> Void) {
        self.currentSortOrder = currentSortOrder
        self.onSortOrderChanged = onSortOrderChanged
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        ascendingButton.setTitle(SortOrder.ascending.description, for: .normal)
        ascendingButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        ascendingButton.addTarget(self, action: #selector(selectAscending), for: .touchUpInside)
        
        descendingButton.setTitle(SortOrder.descending.description, for: .normal)
        descendingButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        descendingButton.addTarget(self, action: #selector(selectDescending), for: .touchUpInside)
        
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.distribution = .fillEqually
        
        buttonStackView.addArrangedSubview(ascendingButton)
        buttonStackView.addArrangedSubview(descendingButton)
        
        addSubview(buttonStackView)
        
        setupConstraints()
        
        updateSelectedButton()
    }
    
    private func setupConstraints() {
        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    @objc private func selectAscending() {
        currentSortOrder = .ascending
        updateSelectedButton()
        onSortOrderChanged(currentSortOrder)
    }
    
    @objc private func selectDescending() {
        currentSortOrder = .descending
        updateSelectedButton()
        onSortOrderChanged(currentSortOrder)
    }
    
    private func updateSelectedButton() {
        if currentSortOrder == .ascending {
            ascendingButton.setTitleColor(.blue, for: .normal)
            descendingButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        } else {
            descendingButton.setTitleColor(.blue, for: .normal)
            ascendingButton.setTitleColor(AppColors.primaryTitleColor, for: .normal)
        }
    }
}
