//
//  CourseBottomHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import UIKit


class CourseBottomHeaderView: UICollectionReusableView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "获取视频"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configLabel(title: String) {
        label.text = title
    }
    
    private func setupViews() {
        backgroundColor = .white
        
        addSubview(containerView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
}
