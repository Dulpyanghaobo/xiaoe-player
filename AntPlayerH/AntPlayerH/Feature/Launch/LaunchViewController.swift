import UIKit
import SnapKit

enum LaunchType {
    case firstTime
    case notFirstTime
}

class LaunchViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private var launchType: LaunchType = .firstTime // 根据实际情况设置

    init(launchType: LaunchType) {
        self.launchType = launchType
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupUI()
    }

    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        
        scrollView.isPagingEnabled = self.launchType == .firstTime
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.bounces = false // Disable bouncing

        pageControl.numberOfPages = self.launchType == .firstTime ? 3 : 1
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = self.launchType == .firstTime ? .white : .clear

        setupConstraints()
        setupViews()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
        }
    }

    private func setupViews() {
        let views = self.launchType == .firstTime ? [createFirstView(), createSecondView(), createThirdView()]: [createFourthView()]
        var previousView: UIView?

        for (index, view) in views.enumerated() {
            scrollView.addSubview(view)

            view.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.height.equalTo(self.view)
                if let previousView = previousView {
                    make.left.equalTo(previousView.snp.right)
                } else {
                    make.left.equalToSuperview()
                }
                if index == views.count - 1 {
                    make.right.equalToSuperview()
                }
            }
            previousView = view
        }
    }
    
    
    private func createFirstView() -> UIView {
        let containerView = UIView()
        let backImage = UIImageView.init(image: UIImage(named: "LaunchImage1")!)
        containerView.addSubview(backImage)
        backImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let skipButton = UIButton.init(type: .custom)
        skipButton.setTitle("跳过", for: .normal)
        skipButton.setTitleColor(AppColors.primaryE6E6E6Color, for: .normal)
        skipButton.titleLabel?.font = AppFonts.primary12Font
        skipButton.backgroundColor = AppColors.primary060606Color.withAlphaComponent(0.09)
        skipButton.layer.cornerRadius = 14
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)

        
        containerView.addSubview(skipButton)

        skipButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(statusBarHeight)
            make.right.equalToSuperview().offset(-20)
            make.size.equalTo(CGSize.init(width: 54, height: 28))
        }

        return containerView
    }

    private func createSecondView() -> UIView {
        let containerView = UIView()
        let backImage = UIImageView.init(image: UIImage(named: "LaunchImage2")!)
        containerView.addSubview(backImage)
        backImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return containerView
    }

    private func createThirdView() -> UIView {
        let containerView = UIView()
        let backImage = UIImageView.init(image: UIImage(named: "LaunchImage3")!)
        containerView.addSubview(backImage)
        backImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let experienceButton = UIButton.init(type: .custom)

        experienceButton.setTitle("立即体验", for: .normal)
        experienceButton.setTitleColor(.white, for: .normal)
        experienceButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        experienceButton.layer.borderWidth = 1
        experienceButton.layer.borderColor = UIColor.white.cgColor
        experienceButton.layer.cornerRadius = 20
        experienceButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)

        containerView.addSubview(experienceButton)

        experienceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-84)
            make.width.equalTo(168)
            make.height.equalTo(40)
        }

        return containerView
    }

    private func createFourthView() -> UIView {
        let containerView = UIView()
        let backImage = UIImageView.init(image: UIImage(named: "LaunchImage4")!)
        containerView.addSubview(backImage)
        backImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let imageView = UIImageView(image: UIImage(named: "huoyi"))
        imageView.contentMode = .scaleAspectFit
        containerView.addSubview(imageView)

        let imageLabel = UIImageView.init(image: UIImage.init(named: "mayibofangqi"))
        containerView.addSubview(imageLabel)

        let label2 = UILabel()
        label2.text = "Ma Yi P L A Y E R"
        label2.font = UIFont(name: "Segoe UI-Regular", size: 18)
        label2.textColor = UIColor(red: 221/255, green: 235/255, blue: 251/255, alpha: 1.0)
        containerView.addSubview(label2)

        let label3 = UILabel()
        label3.text = "新时代 新体验 新创意"
        label3.font = UIFont.systemFont(ofSize: 20)
        label3.textColor = UIColor(red: 221/255, green: 235/255, blue: 251/255, alpha: 1.0)
        containerView.addSubview(label3)

        let label4 = UILabel()
        label4.text = "感受不一样的学习乐趣！"
        label4.font = UIFont(name: "Segoe UI-Regular", size: 12)
        label4.textColor = UIColor(red: 221/255, green: 235/255, blue: 251/255, alpha: 1.0)
        containerView.addSubview(label4)
        
        let experienceButton = UIButton.init(type: .custom)

        experienceButton.setTitle("立即体验", for: .normal)
        experienceButton.setTitleColor(.white, for: .normal)
        experienceButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        experienceButton.layer.borderWidth = 1
        experienceButton.layer.borderColor = UIColor.white.cgColor
        experienceButton.layer.cornerRadius = 20
        experienceButton.addTarget(self, action: #selector(enterButtonTapped), for: .touchUpInside)
        containerView.addSubview(experienceButton)
        // Constraints
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-150)
            make.width.height.equalTo(140)
        }

        imageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.size.equalTo(CGSize.init(width: 230, height: 48))
        }

        label2.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageLabel.snp.bottom).offset(10)
        }

        label3.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label2.snp.bottom).offset(125)
        }

        label4.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(label3.snp.bottom).offset(12)
        }

        experienceButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-84)
            make.width.equalTo(168)
            make.height.equalTo(40)
        }

        return containerView
    }

    @objc private func enterButtonTapped() {
        navigateToHomePage()
    }

    @objc private func skipButtonTapped() {
        navigateToHomePage()
    }

    private func navigateToHomePage() {
        //        self.navigationController?.pushViewController(LoginViewController(), animated: true)
        AppRouter.shared.navigate(to: .course(courseType: .online))
    }
}

extension LaunchViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
}
