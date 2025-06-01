//
//  MineHeaderViewManager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//
import UIKit

enum MineHeaderButtonType {
    case deviceManagement
    case onlineFeedback
    case all
}

protocol MineHeaderViewManagerDelegate: AnyObject {
    func didTapButton(type: MineHeaderButtonType)
}
import UIKit

class MineHeaderViewManager {
    weak var delegate: MineHeaderViewManagerDelegate?

    @MainActor func createHeaderView() -> UIView {
        let headerContainerView = UIView()
        let backgourdImageView02 = UIImageView(image: UIImage(named: "mine_background_icon_01"))
        headerContainerView.addSubview(backgourdImageView02)
        backgourdImageView02.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        let backgourdImageView = UIImageView(image: UIImage(named: "mine_background_icon"))
        headerContainerView.addSubview(backgourdImageView)
        backgourdImageView.contentMode = .scaleToFill
        backgourdImageView.clipsToBounds = true
        backgourdImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let backgourdImageView03 = UIImageView(image: UIImage(named: "default_image"))
        backgourdImageView03.layer.cornerRadius = 40
        backgourdImageView03.clipsToBounds = true
        headerContainerView.addSubview(backgourdImageView03)
        backgourdImageView03.snp.makeConstraints { make in
            make.centerY.equalTo(backgourdImageView02.snp.bottom).offset(-12)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(88)
        }

        let avatarImageView = UIImageView()
        avatarImageView.image = UIImage(named: "default_profile")
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        headerContainerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerY.centerX.equalTo(backgourdImageView03)
            make.width.height.equalTo(80)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textAlignment = .center
        headerContainerView.addSubview(nameLabel)
        nameLabel.textColor = AppColors.primaryTitleColor
        nameLabel.font = AppFonts.primaryNavFont
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        let expiryLabel = UILabel()
        expiryLabel.text = "有效期: 2024-12-31"
        expiryLabel.textAlignment = .center
        expiryLabel.textColor = AppColors.primaryTitleColor
        expiryLabel.font = AppFonts.primary14Font
        headerContainerView.addSubview(expiryLabel)
        expiryLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }

        let buttonsView = setupButtons()
        headerContainerView.addSubview(buttonsView)
        buttonsView.snp.makeConstraints { make in
            make.top.equalTo(expiryLabel.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(80)
        }
        let loginResponse = UserManager.shared.loadLoginResponse()
        guard let userInfo = loginResponse?.userInfo else { return UIView.init()}
        if let imageUrl = URL(string: userInfo.avatar ?? "") {
            avatarImageView.kf.setImage(with: imageUrl)
         }
        nameLabel.text = userInfo.username
        expiryLabel.text = "有效期: \((userInfo.expireTime ?? ""))"
        headerContainerView.backgroundColor = .white
        headerContainerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 364)
        
        return headerContainerView
    }

    private func setupButtons() -> UIView {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .horizontal
        buttonStackView.distribution = .fillEqually
        buttonStackView.alignment = .center
        buttonStackView.spacing = 10
        let buttonTitles = ["设备管理", "在线反馈", "全部"]
        let buttonImages = ["shebeiguanli_icon", "zaixianfankui_icon", "quanbu_icon"]
        for (index, title) in buttonTitles.enumerated() {
            let button = ImageTextView(imageName: buttonImages[index], title: title)
            button.tapCallback = { [weak self] in
                let buttonType: MineHeaderButtonType
                switch index {
                case 0:
                    buttonType = .deviceManagement
                case 1:
                    buttonType = .onlineFeedback
                case 2:
                    buttonType = .all
                default:
                    return
                }
                self?.delegate?.didTapButton(type: buttonType)
            }
            buttonStackView.addArrangedSubview(button)
        }
        return buttonStackView
    }
}
