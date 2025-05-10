//
//  CourseSectionHeaderView.swift
//  AntPlayerH
//
//  Created by i564407 on 7/30/24.
//
import UIKit
import SnapKit
import Kingfisher
@available(iOS 16.0, *)
class CoursePlayerSectionHeaderView: UITableViewHeaderFooterView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let studentCountLabel = UILabel()
    private let courseCountLabel = UILabel()
    private let contactButton = UIButton()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
        
        titleLabel.font = AppFonts.primary14Font
        titleLabel.textColor = AppColors.primary343434BackColor
        contentView.addSubview(titleLabel)
        
        descLabel.font = AppFonts.primary12Font
        descLabel.textColor = AppColors.primaryTitle2Color
        contentView.addSubview(descLabel)
        
        studentCountLabel.font = AppFonts.primary12Font
        studentCountLabel.textColor = AppColors.primaryCDCDCDBackColor
        contentView.addSubview(studentCountLabel)
        
        courseCountLabel.font = AppFonts.primary12Font
        courseCountLabel.textColor = AppColors.primaryCDCDCDBackColor
        
        contentView.addSubview(courseCountLabel)
        
        contactButton.setTitle("联系老师", for: .normal)
        contactButton.setTitleColor(.white, for: .normal)
        contactButton.titleLabel?.font = AppFonts.primary12Font
        contactButton.layer.cornerRadius = 14
        contactButton.backgroundColor = AppColors.themeColor
        contactButton.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        contentView.addSubview(contactButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(74)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(16)
            make.top.equalTo(imageView)
            make.trailing.equalTo(contactButton.snp.leading).offset(-8)
        }
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.trailing.equalTo(titleLabel)
        }
        
        studentCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(descLabel.snp.bottom).offset(8)
        }
        
        courseCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(studentCountLabel.snp.trailing).offset(16)
            make.centerY.equalTo(studentCountLabel)
        }
        
        contactButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(32)
        }
    }
    
    @objc func contactButtonTapped() {
        let contactButton = ConnectTeacherPopupView(frame: CGRect(x: 0, y: 0, width: 300, height: 332))
        let popview = PopupView(contentView: contactButton, popupType: .center, animationType: .fade)
        PopupManager.shared.showPopup(popview)
    }
    
    func configure(merchantBaseInfoResponse: MerchantBaseInfoResponse) {
        titleLabel.text = merchantBaseInfoResponse.merchantName
        descLabel.text = merchantBaseInfoResponse.merchantTeacherPhone
        guard let studentNumbs = merchantBaseInfoResponse.studentNumbs, let courseInfoNumbs = merchantBaseInfoResponse.courseInfoNumbs else { return  }
        studentCountLabel.text = "学生人数: \(String(describing: studentNumbs)) |"
        courseCountLabel.text = "课程数量: \(String(describing: courseInfoNumbs))"
        if let url = URL(string: merchantBaseInfoResponse.merchantPhoto ?? "") {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "course_default_image"))
        }
    }
}
