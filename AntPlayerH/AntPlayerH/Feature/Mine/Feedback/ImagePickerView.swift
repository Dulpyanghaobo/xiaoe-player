//
//  File.swift
//  AntPlayerH
//
//  Created by i564407 on 7/21/24.
//
import UIKit
import SnapKit
import PhotosUI

class ImagePickerView: UIView {
    
    private let collectionView: UICollectionView
    private let uploadButton = UIButton(frame: .zero)
    private let placeholderLabel = UILabel()
    
    var images: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
            updateViewState()
        }
    }
    
    var onImageAdded: ((UIImage) -> Void)?
    
    override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: 50, height: 50)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(collectionView)
        addSubview(uploadButton)
        addSubview(placeholderLabel)
        
        uploadButton.setImage(UIImage(named: "tianjiatupian_icon"), for: .normal)
        uploadButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
        
        uploadButton.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        placeholderLabel.snp.makeConstraints { make in
            make.left.equalTo(uploadButton.snp.right).offset(2)
            make.centerY.equalTo(uploadButton.snp.centerY)
        }
        
        placeholderLabel.text = "添加图片"
        placeholderLabel.textColor = AppColors.primaryTitle2Color
        placeholderLabel.textAlignment = .left
        placeholderLabel.font = AppFonts.primary14Font
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ImageCell")
        collectionView.register(AddButtonCell.self, forCellWithReuseIdentifier: "AddButtonCell")
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateViewState()
    }
    
    private func updateViewState() {
        placeholderLabel.isHidden = !images.isEmpty
        uploadButton.isHidden = !images.isEmpty
        collectionView.isHidden = images.isEmpty
    }
    
    @objc private func addImageTapped() {
        if let viewController = findViewController() {
            PhotoPicker.presentPhotoPicker(from: self.findViewController() ?? UIViewController(), selectionLimit: 3) { [weak self] selectedImages in
                guard let self = self else { return }
                self.images.append(contentsOf: selectedImages)
                selectedImages.forEach { self.onImageAdded?($0) }
            }
        }
    }

}

extension ImagePickerView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1 // +1 for the add button cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == images.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddButtonCell", for: indexPath) as! AddButtonCell
            cell.addButton.addTarget(self, action: #selector(addImageTapped), for: .touchUpInside)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
            let imageView = UIImageView(image: images[indexPath.item])
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            cell.contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            return cell
        }
    }
}

class AddButtonCell: UICollectionViewCell {
    let addButton = UIButton(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .large)
        let image = UIImage(systemName: "plus.square", withConfiguration: config)
        addButton.setImage(image, for: .normal)
        addButton.imageView?.contentMode = .scaleToFill
        addButton.tintColor = AppColors.primaryBackground01Color
        addButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // Add some padding
        
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
