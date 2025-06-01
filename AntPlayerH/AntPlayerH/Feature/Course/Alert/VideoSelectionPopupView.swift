//
//  VideoSelectionPopupView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/8/24.
//

import UIKit
import SnapKit
import MobileCoreServices
import IJKMediaFramework


class VideoSelectionPopupView: UIView {
    var onDocumentPicked: ((URL) -> Void)?
    let titleLabel = UILabel()
    let localVideoView = CustomVideoView(title: "本地视频", desc: "在手机SD卡或外接U盘中查找视频文件", image: UIImage(named: "bendishipin_icon"))
    let networkTransferView = CustomVideoView(title: "局域网快速传输", desc: "同WIFI下可快速通过网址传输视频文件", image: UIImage(named: "saoyisao_icon"))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.backgroundColor = .white
        titleLabel.text = "获取视频"
        titleLabel.font = AppFonts.primaryTitleFont
        titleLabel.textAlignment = .center

        addSubview(titleLabel)
        addSubview(localVideoView)
        addSubview(networkTransferView)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }
        localVideoView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.height.equalTo(56)
        }
        networkTransferView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(30)
            make.top.equalTo(localVideoView.snp.bottom).offset(16)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setupGestureRecognizers() {
        let localVideoTap = UITapGestureRecognizer(target: self, action: #selector(localVideoTapped))
        localVideoView.addGestureRecognizer(localVideoTap)
        localVideoView.isUserInteractionEnabled = true

        let networkTransferTap = UITapGestureRecognizer(target: self, action: #selector(networkTransferTapped))
        networkTransferView.addGestureRecognizer(networkTransferTap)
        networkTransferView.isUserInteractionEnabled = true
    }

    @objc private func localVideoTapped() {
        // 处理本地视频逻辑
        // 创建文件选择器
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMovie as String], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet // 设置展示样式
        // 显示文件选择器
        if let viewController = UIViewController.currentViewController() {
            viewController.present(documentPicker, animated: true, completion: nil)
        }
    }

    @objc private func networkTransferTapped() {
//        let fileServer = FileUploadServer.init()
//        let serverText = fileServer.startServer()
//        // 处理局域网传输逻辑
//        let popView = NetworkTransferContentView.init()
//        popView.configText(with: serverText ?? "")
//        fileServer.fileUploadCompletionHandler = { filePath in
//            DispatchQueue.main.async {
//                if let window = UIApplication.shared.currentKeyWindow {
//                    window.makeToast("文件已保存到: \(filePath)")
//                }
//            }
//        }
//        let popup = PopupView(contentView: popView, popupType: .center, animationType: .fade)

        // 显示弹窗
//        PopupManager.shared.showPopup(popup)
    }
}

class CustomVideoView: UIView {
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let imageView = UIImageView()

    init(title: String, desc: String, image: UIImage?) {
        super.init(frame: .zero)
        setupView(title: title, desc: desc, image: image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(title: String, desc: String, image: UIImage?) {
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(imageView)

        titleLabel.text = title
        descLabel.text = desc
        imageView.image = image

        titleLabel.font = AppFonts.primaryTitleFont
        titleLabel.textColor = AppColors.primaryTitleColor

        descLabel.font = AppFonts.primary14Font
        descLabel.textColor = AppColors.primaryDescColor

        // 使用 SnapKit 设置约束
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(5)
            make.trailing.equalToSuperview().offset(-10) // 防止超出视图边界
        }
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.leading)
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.trailing.equalToSuperview().offset(-10) // 防止超出视图边界
        }
    }
}

extension VideoSelectionPopupView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        onDocumentPicked?(url)

    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("文件选择器被取消")
    }
}

