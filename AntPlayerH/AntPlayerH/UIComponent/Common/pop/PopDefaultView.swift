import UIKit

@available(iOS 16.0, *)
class DefaultView: UIView {
    
    private let titleLabel = UILabel()
    private let msgLabel = UILabel()
    private let actionButtonsListView = UIStackView()
    
    // Callback dictionary to hold button titles and their corresponding actions
    private var buttonActions: [String: () -> Void] = [:]
    
    // Initialize with an optional title
    init(title: String?, message: String, buttonTitles: [String: () -> Void]) {
        super.init(frame: .zero)
        self.buttonActions = buttonTitles
        setupView(title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView(title: String?, message: String) {
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        // Set up title label if title is provided
        if let title = title {
            titleLabel.text = title
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            addSubview(titleLabel)
        } else {
            titleLabel.isHidden = true // Hide title label if no title is provided
        }
        
        msgLabel.text = message
        msgLabel.font = AppFonts.primary14Font
        msgLabel.textAlignment = .center
        msgLabel.numberOfLines = 0
        
        actionButtonsListView.axis = .horizontal
        actionButtonsListView.spacing = 10
        actionButtonsListView.distribution = .fillEqually
        
        // Create buttons and add them to the stack view
        let buttonTitlesArray = Array(buttonActions.keys)
        let buttonCount = buttonTitlesArray.count
        
        for (index, title) in buttonTitlesArray.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(title, for: .normal)
            button.layer.cornerRadius = 8
            button.addAction(UIAction { [weak self] _ in
                self?.buttonActions[title]?()
                if let popupView = self?.superview as? PopupDismissable {
                    popupView.dismissPopup()
                }
            }, for: .touchUpInside)
            if buttonCount == 1 {
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = AppColors.themeColor
            } else {
                if index == buttonCount - 1 {
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = AppColors.themeColor
                } else {
                    button.setTitleColor(.gray, for: .normal)
                }
            }
            actionButtonsListView.addArrangedSubview(button)
        }
        
        addSubview(msgLabel)
        addSubview(actionButtonsListView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Calculate the width based on screen size
        let screenWidth = UIScreen.main.bounds.width
        let popupWidth = (290.0 / 375.0) * screenWidth
        let popupHeight = ( 150 / 290) * screenWidth
        self.snp.makeConstraints { make in
            make.width.equalTo(popupWidth) // Set the width of the popup
            make.height.equalTo(popupHeight)
        }
        
        // Set constraints for titleLabel if visible
        if !titleLabel.isHidden {
            titleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(16)
                make.centerX.equalToSuperview()
                make.left.right.equalToSuperview().inset(16)
            }
        }
        
        msgLabel.snp.makeConstraints { make in
            if titleLabel.isHidden {
                make.top.equalToSuperview().offset(50)
            } else {
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
            }
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
        }
        
        actionButtonsListView.snp.makeConstraints { make in
            make.top.equalTo(msgLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(48)
        }
    }
}
