//
//  AdverView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/12/24.
//

import UIKit
import SnapKit
import AVFoundation

class AdverView: UIView {
    private var adverDataList: [AdverData]?
    private var visibleAdverData: AdverData?
    private var currentTime: TimeInterval = 0
    private let adImageView = UIImageView()
    private let adTitleLabel = UILabel()
    private let closeButton = UIButton(type: .custom)
    var isOpenAdv: Bool = false
    private let safariVC = SafariViewController()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    var onAdvSelected: ((Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.cornerRadius = 10
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func updateAdVDataList(_ adDataList: [AdverData]) {
        self.adverDataList = adDataList
        setupUI()
    }

    private func setupUI() {

        clipsToBounds = true

        addSubview(adImageView)
        adImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        adImageView.isUserInteractionEnabled = true
        adImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openAdLink)))
        
        adTitleLabel.text = "广告"
        adTitleLabel.textColor = .white
        adTitleLabel.backgroundColor = .black.withAlphaComponent(0.03)
        addSubview(adTitleLabel)
        adTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(adImageView.snp.top).offset(8)
            make.left.equalToSuperview().inset(16)
        }

        addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(adImageView.snp.top).offset(8)
            make.right.equalToSuperview().inset(8)
            make.size.equalTo(CGSize.init(width: 24, height: 24))
        }
        closeButton.setImage(UIImage.init(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc func closeButtonTapped() {
        self.isOpenAdv = false
        self.player?.pause()
        self.removeFromSuperview()
    }


    func updateAdData(with adData: AdverData) {
        guard let bizData = adData.bizData else { return }
        if let adType = bizData.adType {
            switch adType {
            case 1:
                adImageView.kf.setImage(with: URL(string: bizData.adUrl ?? ""))
                adTitleLabel.text = bizData.adTitle
            case 2:
                // Load video instead of an image
                setupVideoPlayer(with: bizData.adUrl)
                adTitleLabel.text = bizData.adTitle
            default:
                break
            }
        }
    }
    
    private func setupVideoPlayer(with urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = adImageView.bounds
        adImageView.layer.addSublayer(playerLayer!)
        player?.play()
    }

    func updateCurrentTime(_ currentTime: TimeInterval) {
        self.currentTime = currentTime
        updateVisibleAdverData()
    }
    
    
    private func updateVisibleAdverData() {
        guard let adverDataList = self.adverDataList else {
            self.isHidden = true
            return
        }
        for adverData in adverDataList {
            if let showAdverData = adverData.videoTime {
                if Int(currentTime) == Int(TimeInterval(showAdverData)/1000){
                    self.visibleAdverData = adverData
                }
            }
        }

        if let visibleAdverData = visibleAdverData {
            if self.isOpenAdv == false {
                updateAdData(with: visibleAdverData)
                self.isOpenAdv = true
                self.onAdvSelected?(true)
            }
            self.isHidden = false
        } else {
        }
    }
    @objc private func openAdLink() {
        guard let bizData = self.visibleAdverData?.bizData, let targetUrl = bizData.targetUrl, let url = URL(string: targetUrl), let viewController =  self.findViewController() else { return }
        safariVC.openURL(url, from: viewController)
    }
}
