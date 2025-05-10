//
//  ColorCollectionView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/18/24.
//

import UIKit

class ColorCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let colors: [[BulletSettings.FontColor]] = [
        [BulletSettings.FontColor._fefefc, BulletSettings.FontColor._e50113, BulletSettings.FontColor._fdf106, BulletSettings.FontColor._039744, BulletSettings.FontColor._02a0e7, BulletSettings.FontColor._e2037e, BulletSettings.FontColor._91c421],
        [BulletSettings.FontColor._022d71, BulletSettings.FontColor._f2ad2c, BulletSettings.FontColor._693b7c, BulletSettings.FontColor._87bfcb, BulletSettings.FontColor._917939, BulletSettings.FontColor._597ef7, BulletSettings.FontColor._b37feb],
        [BulletSettings.FontColor._722ed1, BulletSettings.FontColor._eb2f96, BulletSettings.FontColor._52c41a, BulletSettings.FontColor._13c2c2, BulletSettings.FontColor._1890ff, BulletSettings.FontColor._a0d911, BulletSettings.FontColor._faad14]
    ]

    private var collectionView: UICollectionView!
    
    var onColorSelected: ((BulletSettings.FontColor) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors[section].count
    }


    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        cell.configure(with: colors[indexPath.section][indexPath.item].color)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            onColorSelected?(colors[indexPath.section][indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 22, height: 22)
    }
}

// 自定义颜色Cell
class ColorCell: UICollectionViewCell {
    private let colorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        colorView.layer.cornerRadius = 4
        contentView.addSubview(colorView)

        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
}

// UIColor 扩展，用于将颜色转换为 HEX 字符串
