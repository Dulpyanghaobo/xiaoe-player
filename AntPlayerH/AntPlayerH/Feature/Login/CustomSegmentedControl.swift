//
//  CustomSegmentedControl.swift
//  AntPlayerH
//
//  Created by i564407 on 7/17/24.
//
import UIKit
import SnapKit

class CustomSegmentedControl: UIView {
    
    private let segmentedControl = UISegmentedControl(items: ["验证码登录", "账号登录"])
    private let slidingView = UIView()
    var onSelectionChange: ((Int) -> Void)?
    
    var selectedIndex: Int = 0 {
        didSet {
            onSelectionChange?(selectedIndex)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .clear
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: AppColors.themeColor], for: .selected)
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

    }
    
    @objc private func segmentedControlValueChanged() {
        selectedIndex = segmentedControl.selectedSegmentIndex
    }
}
