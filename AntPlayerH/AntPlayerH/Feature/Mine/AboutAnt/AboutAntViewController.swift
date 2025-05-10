//
//  AboutAntViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 8/2/24.
//

import UIKit

class AboutAntViewController: BaseViewController {
    private let backImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let urlLabel = UILabel()
    private let companyImageView = UIImageView()
    private let contentLabel = UILabel()
    
    private let model: AboutNiudunResponse?
    
    init(model: AboutNiudunResponse?) {
        self.model = model
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        guard let model = self.model else { return }
        configData(model: model)
    }
    override func setupNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func setupUI() {
        // 设置背景图片
        backImageView.image = UIImage(named: "about_ant_background")
        backImageView.contentMode = .scaleToFill
        // 添加内容视图
        view.addSubview(backImageView)
        backImageView.snp.makeConstraints { make in
            make.top.equalToSuperview() // 背景图片从顶部开始
            make.left.right.equalToSuperview() // 背景图片宽度等于屏幕宽度
            make.height.equalTo(screenHeight) // 设置一个你需要的高度，或者使用动态计算的高度
        }
        // 设置图标
        view.addSubview(iconImageView)
        iconImageView.image = UIImage(named: "ant_logo")
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.layer.cornerRadius = 50
        iconImageView.layer.masksToBounds = true
        iconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(navigationFullHeight + 34)
            make.width.height.equalTo(100)
        }

        
        // 设置标题
        view.addSubview(titleLabel)
        titleLabel.text = "蚂蚁播放器"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 26)
        titleLabel.textColor = AppColors.themeColor
        titleLabel.textAlignment = .center
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        
        // 设置 URL
        view.addSubview(urlLabel)
        urlLabel.text = "www.jnplayer.com"
        urlLabel.font = UIFont.systemFont(ofSize: 16)
        urlLabel.textAlignment = .center
        urlLabel.textColor = AppColors.themeColor
        urlLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
        }
        
        // 设置公司图片
        view.addSubview(companyImageView)
        companyImageView.image = UIImage(named: "id_card_background")
        companyImageView.contentMode = .scaleToFill
        companyImageView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(26)
            make.top.equalTo(urlLabel.snp.bottom).offset(40)
            make.height.equalTo(173)
        }
        
        // 设置内容标签
        view.addSubview(contentLabel)
        contentLabel.text = "  包图网成立于2016年，隶属于上海包图网络科技有限公司，是中国人气优质创意内容供给平台。质创意内容供给平台。平台联合30w+顶尖设计师、创意工作室以及国内外输出正版的图片、视频、音频、源文平台联合30w+顶尖设计师、创意工作室以及国内外输出正版的图片、视频、音频、源文件素材..."
        contentLabel.font = UIFont.systemFont(ofSize: 16)
        contentLabel.textAlignment = .left
        contentLabel.numberOfLines = 0
        contentLabel.snp.makeConstraints { make in
            make.left.right.equalTo(companyImageView)
            make.top.equalTo(companyImageView.snp.bottom).offset(30)
        }
    }
    
    private func configData(model: AboutNiudunResponse) {
        contentLabel.text = model.company_introduct
        if let url = URL(string: model.branch_icon ?? "") {
            // 使用一个库如 SDWebImage 来加载图片
            iconImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_image"))
        }
        if let url = URL(string: model.office_image ?? "") {
            // 使用一个库如 SDWebImage 来加载图片
            companyImageView.kf.setImage(with: url, placeholder: UIImage(named: "default_image"))
        }
        urlLabel.text = model.office_url
        titleLabel.text = model.software_name ?? "蚂蚁播放器"
    }
}
