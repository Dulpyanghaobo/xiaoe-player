import UIKit

enum PopupType {
    case top
    case center
    case bottom
    case right // 新增从右边弹出的弹窗类型
}

enum AnimationType {
    case fade
    case slideFromBottom
    case slideFromRight // 新增从右边滑入的动画类型
    case custom((UIView) -> Void, (UIView) -> Void) // 自定义动画
}

protocol PopupDismissable: AnyObject {
    func dismissPopup()
}

class PopupView: UIView, PopupDismissable {
    private var contentView: UIView
    private var popupType: PopupType
    private var animationType: AnimationType
    var shouldDismissOnBackgroundTap: Bool = true

    var popupBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.5)
    
    init(contentView: UIView, popupType: PopupType, animationType: AnimationType) {
        self.contentView = contentView
        self.popupType = popupType
        self.animationType = animationType
        super.init(frame: UIScreen.main.bounds)
        setupView()
        setupGestures()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRotation), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupView() {
        self.backgroundColor = popupBackgroundColor // 使用新的背景颜色属性
        self.addSubview(contentView)
        positionContentView()
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(backgroundTapped))
        swipeGesture.direction = .down
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func backgroundTapped() {
        if shouldDismissOnBackgroundTap {
            dismiss() // Dismiss the popup if the property is true
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.popupBackgroundColor = color
        self.backgroundColor = color
    }
    
    private func positionContentView() {
        contentView.snp.makeConstraints { make in
            switch popupType {
            case .top:
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(20)
            case .center:
                make.center.equalToSuperview()
            case .bottom:
                make.centerX.equalToSuperview()
                make.bottom.left.right.equalToSuperview().offset(0)
            case .right: // 新增从右边弹出的布局
                  make.top.equalToSuperview().offset(0)
                  make.trailing.equalToSuperview().offset(0)
                  make.width.equalTo(contentView.frame.width)
                  make.height.equalTo(contentView.frame.height)
            }
        }
    }
    
    func show(in view: UIView? = UIApplication.shared.keyWindow) {
        guard let containerView = view else { return }
        containerView.addSubview(self)
        
        switch animationType {
        case .fade:
            self.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        case .slideFromBottom:
            contentView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        case .slideFromRight: // 新增从右边滑入的动画
            contentView.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(contentView.frame.width)
            }
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        case .custom(let showAnimation, _):
            showAnimation(self.contentView)
        }
    }
    
    @objc func dismiss() {
        switch animationType {
        case .fade:
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }) { _ in
                self.removeFromSuperview()
            }
        case .slideFromBottom:
            contentView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(contentView.frame.height)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }) { _ in
                self.removeFromSuperview()
            }
        case .slideFromRight: // 新增从右边滑出的动画
            contentView.snp.updateConstraints { make in
                make.trailing.equalToSuperview().offset(contentView.frame.width)
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            }) { _ in
                self.removeFromSuperview()
            }
        case .custom(_, let dismissAnimation):
            dismissAnimation(self.contentView)
            self.removeFromSuperview()
        }
    }
    
    @objc private func handleRotation() {
        UIView.animate(withDuration: 0.3) {
            self.positionContentView()
        }
    }
    
    func dismissPopup() {
        dismiss() // Call the dismiss method
    }
}

class PopupManager {
    static let shared = PopupManager()
    private var popupQueue: [PopupView] = []
    
    private init() {}
    
    func showPopup(_ popup: PopupView) {
        if let currentPopup = popupQueue.last {
            currentPopup.dismiss()
        }
        popupQueue.append(popup)
        popup.show()
    }
    
    func dismissPopup() {
        if let currentPopup = popupQueue.popLast() {
            currentPopup.dismiss()
        }
    }
}
