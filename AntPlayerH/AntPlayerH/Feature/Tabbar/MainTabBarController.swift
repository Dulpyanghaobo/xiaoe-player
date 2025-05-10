//  Created by i564407 on 7/16/24.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()

    }
    
    
    private func setupViewControllers() {
        let localCourseVC = CourseViewController(courseType: .local)
        let onlineCourseVC = CourseViewController(courseType: .online)
        let mineVC = MineViewController()
        
        // 设置TabBarItem
        localCourseVC.tabBarItem = createTabBarItem(
            title: "媒体库",
            imageName: "bendikecheng_icon",
            selectedImageName: "bendikecheng_icon_1"
        )
        onlineCourseVC.tabBarItem = createTabBarItem(
            title: "文件源",
            imageName: "zaixiankecheng_icon",
            selectedImageName: "zaixiankecheng_icon_1"
        )
        mineVC.tabBarItem = createTabBarItem(
            title: "我的",
            imageName: "wode_icon",
            selectedImageName: "wode_icon_selected"
        )
        
        // 设置TabBar背景颜色
        self.tabBar.backgroundColor = .white
        
        // 创建导航控制器
        let localNav = UINavigationController(rootViewController: localCourseVC)
        let onlineNav = UINavigationController(rootViewController: onlineCourseVC)
        let mineNav = UINavigationController(rootViewController: mineVC)
        
        // 设置TabBar的视图控制器
        setViewControllers([localNav, onlineNav, mineNav], animated: false)
    }
    
    private func createTabBarItem(title: String, imageName: String, selectedImageName: String) -> UITabBarItem {
        return UITabBarItem(
            title: title,
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal)
        )
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarItem.appearance()
        
        // 设置选中状态下的字体颜色
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppColors.themeColor // 可以根据需要更改颜色
        ]
        appearance.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
}
