//
//  CustomBottomSheetViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/17/24.
//

import UIKit
import SnapKit

class CustomBottomSheetViewController: UIViewController {
    
    private let contentViewController: UIViewController
    private let height: CGFloat
    private let headerView: UIView = UIView.init()

    init(contentViewController: UIViewController, height: CGFloat = 300) {
        self.contentViewController = contentViewController
        self.height = height
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headerView.backgroundColor = .white
        
        
        let titleLabel = UILabel()
        titleLabel.text = "我的笔记"
        titleLabel.font = AppFonts.primary18Font
        
        let publishButton = UIButton(type: .custom)
        publishButton.setTitle("发布", for: .normal)
        publishButton.setTitleColor(AppColors.themeColor, for: .normal)
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
        headerView.addSubview(titleLabel)
        headerView.addSubview(publishButton)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        publishButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
        }
        // 设置阴影
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        headerView.layer.shadowRadius = 4
        
        view.addSubview(headerView)
        setupContentViewController()
        setupDismissGesture()
    }

    private func setupContentViewController() {
        addChild(contentViewController)
        view.addSubview(contentViewController.view)
        view.addSubview(headerView)
        // 使用 SnapKit 进行布局
        contentViewController.view.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(height-38)
            make.bottom.equalToSuperview()
        }
        
        contentViewController.didMove(toParent: self)
        headerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(38)
            make.bottom.equalTo(contentViewController.view.snp.top)
        }
    }
    
    private func setupDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    @objc func publishButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}
