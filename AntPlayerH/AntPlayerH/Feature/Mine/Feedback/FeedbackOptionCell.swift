//
//  FeedbackOptionCell.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//
import UIKit

class FeedbackOptionCell: UITableViewCell {
    private let optionLabel = UILabel()
    private let selectButton = UIButton()
    
    private var viewModel: FeedbackOptionViewModel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(optionLabel)
        contentView.addSubview(selectButton)

        optionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }

        selectButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        let normalImage = UIImage(systemName: "circle")?.withTintColor(UIColor(hex: "808080"), renderingMode: .alwaysOriginal)
        let selectedImage = UIImage(systemName: "circle.inset.filled")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
        selectButton.setImage(normalImage, for: .normal)
        selectButton.setImage(selectedImage, for: .selected)
//        selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
    }

    func configure(with viewModel: FeedbackOptionViewModel) {
        self.viewModel = viewModel
        
        // Update UI with view model data
        optionLabel.text = viewModel.title
        selectButton.isSelected = viewModel.isSelected
        
        // Observe changes in view model
        viewModel.onStateChanged = { [weak self] in
            self?.updateUI()
        }
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        selectButton.isSelected = viewModel.isSelected
    }
//    
//    @objc private func selectButtonTapped() {
//        viewModel?.toggleSelection()
//    }
}
