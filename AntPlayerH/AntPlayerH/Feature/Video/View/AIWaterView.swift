//
//  AIWaterView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/17/24.
//
import UIKit
import Kingfisher

class AIWaterView: UIView {
    
    var currentWaterData: AIWaterData?
    var waterDatas: [AIWaterData]?
    
    // MARK: - Setup View
    private func setupView(with waterData: AIWaterData) {
        guard let bizData = waterData.bizData else { return }
        
        switch bizData.watermarkType {
        case 1:
            setupImageWatermark(with: bizData)
        case 2:
            setupTextWatermark(with: bizData)
        default:
            break
        }
    }
    
    // MARK: - Image Watermark
    private func setupImageWatermark(with bizData: WatermarkBizData) {
        guard let imageUrlString = bizData.imageUrl, let imageUrl = URL(string: imageUrlString) else { return }
        
        let imageView = UIImageView()
        imageView.kf.setImage(with: imageUrl)
        imageView.alpha = CGFloat(bizData.transparence ?? 100) / 100.0
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(bizData.fixedCustomY ?? 0)),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(bizData.fixedCustomX ?? 0))
        ])
    }
    
    // MARK: - Text Watermark
    private func setupTextWatermark(with bizData: WatermarkBizData) {
        let label = UILabel()
        label.text = bizData.customerContent ?? ""
        label.font = UIFont.systemFont(ofSize: CGFloat(bizData.frontSize ?? 14))
        label.textColor = UIColor(hex: bizData.frontColor ?? "#FFFFFF")
        label.alpha = CGFloat(bizData.transparence ?? 100) / 100.0
        label.sizeToFit()
        self.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: CGFloat(bizData.fixedCustomY ?? 0)),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: CGFloat(bizData.fixedCustomX ?? 0))
        ])
    }
    
    // MARK: - Update Watermark Display Based on Current Time
    func updateAIWaterDatas(for currentTime: TimeInterval) {
        guard let waterDatas = self.waterDatas else { return }
        
        var matchedWaterData: AIWaterData?
        
        // 遍历所有水印数据，找到匹配的水印
        for waterData in waterDatas {
            if let startTime = waterData.videoStartTime,
               let endTime = waterData.videoEndTime,
               currentTime >= TimeInterval(startTime) && currentTime <= TimeInterval(endTime) {
                matchedWaterData = waterData
                break
            } else {
                matchedWaterData = nil
            }
        }
        
        guard let matchedWaterData = matchedWaterData else { return }
        // 更新水印视图
        // 如果找到匹配的水印数据，并且不同于当前显示的水印
        currentWaterData = matchedWaterData
        self.subviews.forEach { $0.removeFromSuperview() }  // 清除现有水印视图
        setupView(with: matchedWaterData)  // 显示新的水印
        self.isHidden = false
    }
    
    // MARK: - Update View with New Watermark Data
    func updateView(with waterDatas: [AIWaterData]?) {
        self.subviews.forEach { $0.removeFromSuperview() }  // 清除现有的水印视图
        self.waterDatas = waterDatas
        currentWaterData = nil  // 重置当前的水印数据
        self.isHidden = true  // 初始状态下隐藏水印
    }
}
