//
//  MineViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/16/24.
//
import UIKit
import SnapKit
import ZVRefreshing

class MineViewController: BaseViewController {
    private let authManager = AuthManager()
    private let tableViewManager = MineTableViewManager()
    private let headerManager = MineHeaderViewManager()
    private let appconfigManager = AppConfigManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func addStatusBarBackgroundView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let statusBarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: statusBarHeight))
        statusBarBackgroundView.backgroundColor = AppColors.themeColor // 设置你想要的颜色
        view.addSubview(statusBarBackgroundView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func setupTableView() {
        let tableView = tableViewManager.createTableView()
        self.tableViewManager.delegate = self
        self.headerManager.delegate = self
        view.addSubview(tableView)
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.right.left.bottom.equalToSuperview()
        }
        tableView.tableHeaderView = headerManager.createHeaderView()
    }
}

extension MineViewController: MineTableViewManagerDelegate {
    // MineTableViewManagerDelegate 方法
    func didSelectRow(type: MineTableRowType) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        switch type {
        case .identityVerification:
            authManager.getRealStatus { result in
                switch result {
                case .success(let response):
                    let status =  response.data?.status
                    
                    switch status {
                    case 0:
                        // 未实名，展示实名认证弹窗
                        self.showRealNameDialog()
                        
                    case 1:
                        // 实名成功，展示成功弹窗
                        self.showSuccessDialog()
                        
                    case 2:
                        // 实名失败，展示失败弹窗
                        self.showFailureDialog()
                        
                    case 3:
                        // 实名超过10次，禁止继续实名
                        self.showLimitExceededDialog()
                        
                    case 4:
                        // 实名处理中，跳转到IdentityVerificationViewController
                        self.navigateToIdentityVerification()
                        
                    default:
//                        self.navigateToIdentityVerification()

                        self.showRealNameDialog()

                    }
                case .failure(let error):
                    print("Failed to fetch comments: \(error)")
                }
            }

        case .helpCenter:
            appconfigManager.getAppConfig(typeCode: "app_help_center") { result in
                switch result {
                case .success(let response):
                    SafariViewController().openURL(URL.init(string: response.data?.helper_url ?? "https://www.baidu.com")!, from: self)
                case .failure(let error):
                    print("Failed to fetch comments: \(error)")
                }
            }
        case .softwareSettings:
            let settingsVC = SoftwareSettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: false)
        case .aboutAnt:
            appconfigManager.getAboutNiudun { result in
                switch result {
                case .success(let response):
                    guard let model = response.data else { return }
                    let aboutAntVC = AboutAntViewController(model: model)
                    self.navigationController?.pushViewController(aboutAntVC, animated: false)
                case .failure(let error):
                    print("Failed to fetch comments: \(error)")
                }
            }
        case .aboutApp:
            appconfigManager.getAboutApp(completion: { result in
                switch result {
                case .success(let response):
                    guard let model = response.data else { return }
                    let aboutAppVC = AboutAppViewController(aboutAppModel: model)
                    self.navigationController?.pushViewController(aboutAppVC, animated: false)
                case .failure(let error):
                    print("Failed to fetch comments: \(error)")
                }
            })
        case .logout:
            handleLogout()
        }
    }
    
    private func handleLogout() {
        
        // 创建默认视图
        let popView = DefaultView(title: nil, message: "您确定要退出登录吗？", buttonTitles: ["取消":{
            
        }, "确认":{
            self.performLogout()
        }])
        // 创建弹窗
        let popup = PopupView(contentView: popView, popupType: .center, animationType: .fade)
        
        // 显示弹窗
        PopupManager.shared.showPopup(popup)
    }
    
    /// 
    
    private func performLogout() {
        UserDefaults.standard.removeObject(forKey: "userToken")
        UserDefaults.standard.synchronize()
        authManager.logout { result in
            let loginVC = LoginViewController()
            self.navigationController?.pushViewController(loginVC, animated: true)
        }
    }
    // 展示实名认证弹窗
    func showRealNameDialog() {
        let popView = PopupView(contentView: VerificationPopupOneView.init(frame: .zero, verificationPopCallBack: {
            
            let identityVC = IdentityVerificationViewController()
            // Assuming you are in a UIViewController context
            self.navigationController?.pushViewController(identityVC, animated: true)
        }), popupType: .center, animationType: .fade)
        PopupManager.shared.showPopup(popView)
    }

    // 展示成功实名认证弹窗
    func showSuccessDialog() {
        let alert = UIAlertController(title: "成功", message: "实名认证成功！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // 展示实名认证失败弹窗
    func showFailureDialog() {
        let alert = UIAlertController(title: "失败", message: "实名认证失败，请重试！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // 展示实名超过10次的提示
    func showLimitExceededDialog() {
        let alert = UIAlertController(title: "限制", message: "您已超过实名认证次数，请稍后再试！", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    // 跳转到IdentityVerificationViewController
    func navigateToIdentityVerification() {
        let identityVC = IdentityVerificationViewController()
        // Assuming you are in a UIViewController context
        self.navigationController?.pushViewController(identityVC, animated: true)
    }
}
extension MineViewController: MineHeaderViewManagerDelegate {
    func didTapButton(type: MineHeaderButtonType) {
        switch type {
        case .deviceManagement:
            let deviceManagementVC = DeviceManagementViewController()
            navigationController?.pushViewController(deviceManagementVC, animated: false)
        case .onlineFeedback:
            let onlineFeedbackVC = FeedBackViewController()
            navigationController?.pushViewController(onlineFeedbackVC, animated: false)
        case .all:
            SystemAlertManager.showAlert(on: self, title: "功能待开发", message: "此功能待开发")
        }
    }
}
