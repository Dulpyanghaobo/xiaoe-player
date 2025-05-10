//
//  NavigationBarManager.swift
//  AntPlayerH
//
//  Created by i564407 on 8/9/24.
//

import UIKit

class NavigationBarManager {
    
    func configureNavigationBar(for viewController: BaseViewController, style: NavigationBarStyle) {
        viewController.navigationController?.navigationBar.isHidden = false
        
        switch style {
        case .hidden:
            viewController.navigationController?.navigationBar.isHidden = true
        case .defaultStyle:
            viewController.navigationController?.navigationBar.backgroundColor = AppColors.themeColor
            setupDefaultNavigationBar(for: viewController)
            setupCustomBackButton(for: viewController)
        case .whiteStyle:
            viewController.navigationController?.navigationBar.backgroundColor = .white
            setupCustomBackButton(for: viewController)
        case .customStyle(let title, let description, let courseType):
            setupCustomNavigationBar(for: viewController, title: title, description: description, courseType: courseType)
        }
    }
    
    private func setupDefaultNavigationBar(for viewController: BaseViewController) {
        let titleLabel = createLabel(text: "蚂蚁播放器", font: AppFonts.primaryNavFont, textColor: .white)
        let descLabel = createLabel(text: "V1.1.0", font: AppFonts.primary12Font, textColor: .white)
        viewController.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: titleLabel), UIBarButtonItem(customView: descLabel)]
    }
    
    private func setupCustomNavigationBar(for viewController: BaseViewController, title: String, description: String, courseType: CourseType) {
        let titleLabel = createLabel(text: title, font: AppFonts.primaryNavFont, textColor: .white)
        let descLabel = createLabel(text: description, font: AppFonts.primary12Font, textColor: .white)
        viewController.navigationController?.navigationBar.backgroundColor = AppColors.themeColor
        viewController.navigationItem.leftBarButtonItems = [UIBarButtonItem(customView: titleLabel), UIBarButtonItem(customView: descLabel)]
        
        if courseType == .local {
            let addButton = UIBarButtonItem(image: UIImage(named: "tianjia_icon"), style: .done, target: viewController, action: #selector(viewController.addButtonTapped))
            viewController.navigationItem.rightBarButtonItem = addButton
            viewController.navigationItem.rightBarButtonItem?.tintColor = .white
        } else {
            setupRightBarButtonItems(for: viewController)
        }
    }
    
    private func setupRightBarButtonItems(for viewController: BaseViewController) {
        
        let downloadImageView = UIImageView(image: UIImage(named: "xaizai_icon"))
        let searchImageView = UIImageView(image: UIImage(named: "sousuo_icon"))
        let refreshImageView = UIImageView(image: UIImage(named: "shuaxin_icon"))

        downloadImageView.isUserInteractionEnabled = true
//        downloadImageView.addGestureRecognizer(UITapGestureRecognizer(target: viewController, action: #selector(showDownloadCourses)))
        
        searchImageView.isUserInteractionEnabled = true
        searchImageView.addGestureRecognizer(UITapGestureRecognizer(target: viewController, action: #selector(showSearchCourses)))

        viewController.navigationItem.rightBarButtonItems = [
            UIBarButtonItem(customView: refreshImageView),
            UIBarButtonItem(customView: searchImageView),
            UIBarButtonItem(customView: downloadImageView)
        ]
    }
    
    
    @objc private func showSearchCourses() {
        let searchView = CourseSearchView()
        let popView = PopupView(contentView: searchView, popupType: .center, animationType: .fade)
        searchView.onSearch = { [weak self] courseName in
            // self?.viewModel.searchOnlineCourses(courseName: courseName)
        }
        PopupManager.shared.showPopup(popView)
    }
    
    
    private func setupCustomBackButton(for viewController: BaseViewController) {
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "fanhui_icon_1"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backButtonItem = UIBarButtonItem(customView: backButton)
        viewController.navigationItem.leftBarButtonItem = backButtonItem
    }
    
    
    @objc private func backButtonTapped() {
        if let currentVC = UIApplication.shared.currentViewController {
            print("当前的 ViewController 是: \(currentVC)")
            currentVC.navigationController?.popViewController(animated: true)
        }
    }
    
    private func createLabel(text: String, font: UIFont, textColor: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        return label
    }
}
