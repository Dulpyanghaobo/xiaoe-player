//
//  AuthPopupView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//
import UIKit
import SnapKit

// 自定义弹窗系统的主视图
class VerificationPopupOneView: UIView {
    let titleLabel = UILabel()  // 顶部标题
    let descLabel = UILabel()   // 描述标签
    let leftImageView = UIImageView()  // 左侧图片
    let rightImageView = UIImageView() // 右侧图片
    let stackListView = UIStackView() // 存放步骤的堆栈视图
    let bottomButton = UIButton()       // 底部按钮
    let infoLabel1 = UILabel()         // 信息提示标签1
    let infoLabel2 = UILabel()         // 信息提示标签2
    private var verificationPopCallBack: () -> Void
    init(frame: CGRect, verificationPopCallBack: @escaping () -> Void) {
        self.verificationPopCallBack = verificationPopCallBack
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 8
        // 设置 titleLabel
        titleLabel.text = "实名认证 让你快人一步"
        titleLabel.textAlignment = .center
        titleLabel.font = AppFonts.primary18Font
        titleLabel.textColor = AppColors.themeColor
        
        // 设置 descLabel
        descLabel.text = "三个步骤完成认证"
        descLabel.textAlignment = .center
        descLabel.font = AppFonts.primary14Font
        descLabel.textColor = AppColors.themeColor

        // 设置 ImageView
        leftImageView.contentMode = .scaleAspectFit
        rightImageView.contentMode = .scaleAspectFit

        // 组织 stackListView
        stackListView.axis = .horizontal
        stackListView.distribution = .fillEqually
        stackListView.spacing = 10
        
        // 添加三个均等分的 ImageView 到 stackListView
        for i in 0..<3 {
            let view = UIView()
            let imageView = UIImageView()
            imageView.image = UIImage.init(named: "icon_step\(i+1)")
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            let label = UILabel()
            label.text = "实名认证"
            label.textColor = AppColors.themeColor
            label.font = AppFonts.primary14Font
            view.addSubview(label)
            
            imageView.snp.makeConstraints { make in
                make.top.centerX.equalToSuperview()
                make.width.height.equalTo(64)
            }
            
            label.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(4)
                make.centerX.bottom.equalToSuperview()
            }
            stackListView.addArrangedSubview(view)
        }

        // 设置底部按钮
        bottomButton.setTitle("朕知道了", for: .normal)
        bottomButton.addTarget(self, action: #selector(jumpForVerificationTapped), for: .touchUpInside)

        bottomButton.backgroundColor = AppColors.themeColor
        bottomButton.setTitleColor(.white, for: .normal)
        bottomButton.layer.cornerRadius = 23

        // 设置信息提示标签
        infoLabel1.text = "· 需实名认证完成后，才可进行提现操作"
        infoLabel1.textAlignment = .left
        infoLabel1.font = AppFonts.primary14Font
        infoLabel1.numberOfLines = 0
        
        infoLabel2.text = "· 实名认证需填写正确的信息"
        infoLabel2.textAlignment = .left
        infoLabel2.font = AppFonts.primary14Font
        infoLabel2.numberOfLines = 0

        // 添加所有视图到主视图
        addSubview(titleLabel)
        addSubview(descLabel)
        addSubview(leftImageView)
        addSubview(rightImageView)
        addSubview(stackListView)
        addSubview(infoLabel1)
        addSubview(infoLabel2)
        addSubview(bottomButton)

        // 布局视图
        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        leftImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(50)
        }

        rightImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(50)
        }

        stackListView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(120)
        }

        infoLabel1.snp.makeConstraints { make in
            make.top.equalTo(stackListView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        infoLabel2.snp.makeConstraints { make in
            make.top.equalTo(infoLabel1.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        bottomButton.snp.makeConstraints { make in
            make.top.equalTo(infoLabel2.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(22)
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }
    
    @objc func jumpForVerificationTapped() {
        verificationPopCallBack()
        if let popupView = self.superview as? PopupDismissable {
            popupView.dismissPopup()
        }
    }
}
