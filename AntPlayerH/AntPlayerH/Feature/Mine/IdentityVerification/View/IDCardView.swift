//
//  IDCardView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/3/24.
//
import UIKit

protocol IDCardViewDelegate: AnyObject {
    func didRecognizeIDCard(info: UploadSfzResponse, type: Int)
}

class IDCardView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: IDCardViewDelegate?
    private let imageView = UIImageView()
    private let uploadButton = UIButton(type: .custom)
    var type: Int = 1
    init(frame: CGRect, initialImage: UIImage?, type: Int) {
        super.init(frame: frame)
        self.type = type
        setupView(initialImage: initialImage)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView(initialImage: UIImage?) {
        imageView.contentMode = .scaleAspectFill
        imageView.image = initialImage
        addSubview(imageView)
        
        uploadButton.setImage(UIImage(named: "camera_idcard"), for: .normal)
        uploadButton.addTarget(self, action: #selector(uploadButtonTapped), for: .touchUpInside)
        addSubview(uploadButton)
        
        imageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        uploadButton.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).offset(8)
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    @objc private func uploadButtonTapped() {
        let alert = UIAlertController(title: "选择图片", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "上传图片", style: .default, handler: { _ in
            self.presentPhotoPicker()
        }))
        alert.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            self.presentCamera()
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        guard let viewController = self.findViewController() else { return }

        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func presentPhotoPicker() {
        guard let viewController = self.findViewController() else { return }
        PhotoPicker.presentPhotoPicker(from: viewController, selectionLimit: 1) { [weak self] selectedImages in
            guard let self = self, let selectedImage = selectedImages.first else { return }
            self.uploadButton.setImage(selectedImage, for: .normal)
            self.recognizeIDCard(image: selectedImage)
        }
    }
    
    private func presentCamera() {

    }

    
    private func recognizeIDCard(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        AuthManager().uploadSfz(type: self.type, file: imageData) { [weak self] result in
            switch result {
            case .success(let response):
                guard let recognizedInfo = response.data else { return }
                self?.delegate?.didRecognizeIDCard(info: recognizedInfo, type: self?.type ?? 1)
            case .failure(let error):
                print("识别身份证失败: \(error)")
            }
        }
    }
}
