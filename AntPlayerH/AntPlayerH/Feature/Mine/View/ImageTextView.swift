//
//  ImageTextView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/20/24.
//

import UIKit
import SnapKit

class ImageTextView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    var tapCallback: (() -> Void)?

    
    init(imageName: String, title: String) {
        super.init(frame: .zero)
        setupView(imageName: imageName, title: title)
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        tapCallback?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(imageName: String, title: String) {
        // Configure imageView
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        // Configure titleLabel
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = AppFonts.primary14Font

        titleLabel.textColor = AppColors.primaryTitleColor
        addSubview(titleLabel)
        
        // Layout using SnapKit
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40) // Adjust size as needed
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
