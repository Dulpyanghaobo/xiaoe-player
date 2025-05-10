//
//  MyAVPlayerViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/13/24.
//

import UIKit
import AVKit

class MyAVPlayerViewController: AVPlayerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
    }
    
    func loadDocumentPicker(with url: URL) {
        self.playMedia(with: url)
    }

    private func playMedia(with url: URL) {
        let player = AVPlayer(url: url)
        
        self.player = player
        player.play()
    }
    
    private func setupCloseButton() {
        // 创建关闭按钮
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeButtonTapped))
        // 将按钮添加到导航栏的右侧
        self.navigationItem.rightBarButtonItem = closeButton
    }

    @objc private func closeButtonTapped() {
        // 关闭当前视图控制器
        self.dismiss(animated: true, completion: nil)
    }
}
