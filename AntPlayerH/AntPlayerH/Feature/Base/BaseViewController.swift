//
//  BaseViewController.swift
//  AntPlayerH
//
//  Created by i564407 on 7/19/24.
//

import UIKit

enum NavigationBarStyle {
    case hidden
    case defaultStyle
    case whiteStyle
    case customStyle(title: String, description: String, courseType: CourseType)
}
import UIKit

class BaseViewController: UIViewController {
    
    var mediator: AppMediator
    
    init(mediator: AppMediator = AppMediator.shared) {
        self.mediator = mediator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var navigationBarStyle: NavigationBarStyle = .whiteStyle {
        didSet {
            setupNavigationBar()
        }
    }
    
    private var navigationBarManager = NavigationBarManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addStatusBarBackgroundView()
        registerWithMediator()
        setupNavigationBar()
    }
    
    func addStatusBarBackgroundView() {
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        let statusBarBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: statusBarHeight))
        statusBarBackgroundView.backgroundColor = .white
        view.addSubview(statusBarBackgroundView)
    }
    
    func registerWithMediator() {
        mediator.addColleague(self)
    }
    
    func setupNavigationBar() {
        navigationBarManager.configureNavigationBar(for: self, style: navigationBarStyle)
    }
    
    @objc func showDownloadCourses() {
        let downloadVC = DownloadCoursesViewController()
        navigationController?.pushViewController(downloadVC, animated: true)
    }

    @objc func addButtonTapped() {
        let popView = VideoSelectionPopupView(frame: .init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 256))
        popView.onDocumentPicked = {url in
            let avPlayerViewController = MyAVPlayerViewController()
            avPlayerViewController.loadDocumentPicker(with: url)
            self.navigationController?.present(avPlayerViewController, animated: true)
        }
        let popup = PopupView(contentView: popView, popupType: .bottom, animationType: .fade)
        PopupManager.shared.showPopup(popup)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default // or .lightContent, depending on your background color
    }
    
    deinit {
        mediator.removeColleague(self)
    }
}

extension BaseViewController {
    func receive(event: String, from sender: BaseViewController) {
        // Default implementation is empty; subclasses can override as needed
    }
}
