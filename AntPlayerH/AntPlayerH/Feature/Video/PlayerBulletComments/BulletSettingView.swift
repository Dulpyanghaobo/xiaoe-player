//
//  BulletSettingView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/18/24.
//

import UIKit

struct BulletSettings {
    enum FontSize: Int {
        case large = 14
        case small = 10
    }

    enum BulletPosition: Int {
        case top = 1
        case middle = 2
        case bottom = 3
    }

    enum FontColor: String {
        case _fefefc = "#FEFEFC"
        case _e50113 = "#E50113"
        case _fdf106 = "#FDF106"
        case _039744 = "#039744"  // 前缀 `_` 是因为数字开头的变量名不允许
        case _02a0e7 = "#02A0E7"
        case _e2037e = "#E2037E"
        case _91c421 = "#91C421"
        
        case _022d71 = "#022D71"
        case _f2ad2c = "#F2AD2C"
        case _693b7c = "#693B7C"
        case _87bfcb = "#87BFCB"
        case _917939 = "#917939"
        case _597ef7 = "#597EF7"
        case _b37feb = "#B37FEB"
        
        case _722ed1 = "#722ED1"
        case _eb2f96 = "#EB2F96"
        case _52c41a = "#52C41A"
        case _13c2c2 = "#13C2C2"
        case _1890ff = "#1890FF"
        case _a0d911 = "#A0D911"
        case _faad14 = "#FAAD14"
        
        var color: UIColor {
            return UIColor(hex: self.rawValue)
        }
    }

    var fontSize: FontSize
    var position: BulletPosition
    var fontColor: FontColor
}

class BulletSettingView: UIView {
    
    let stackView = UIStackView()
    
    let fontSizeLabel = UILabel()
    let positionLabel = UILabel()
    
    let largeFontButton = UIButton(type: .custom)
    let smallFontButton = UIButton(type: .custom)

    let topPositionButton = UIButton(type: .custom)
    let middlePositionButton = UIButton(type: .custom)
    let bottomPositionButton = UIButton(type: .custom)
    var bulletSettings: BulletSettings?
    let colorLabel = UILabel()
    let colorCollectionView = ColorCollectionView()
    
    
    
    var onSettingsChanged: ((BulletSettings) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        // 配置 UISegmentedControl
        configureFontSizeButtons()
        configurePositionButtons()
        // 设置第一排
        fontSizeLabel.text = "字幕字号"
        fontSizeLabel.textColor = AppColors.primary999999Color
        fontSizeLabel.font = AppFonts.primary12Font
        let fontSizeButtons = createRow(titleLabel: fontSizeLabel, rightViews: [largeFontButton, smallFontButton])

        // 设置第二排
        positionLabel.text = "弹幕位置"
        positionLabel.textColor = AppColors.primary999999Color
        positionLabel.font = AppFonts.primary12Font
        let positionButtons = createRow(titleLabel: positionLabel, rightViews: [topPositionButton, middlePositionButton, bottomPositionButton])

        // 设置第三排
        colorLabel.text = "弹幕颜色"
        colorLabel.textColor = AppColors.primary999999Color
        colorLabel.font = AppFonts.primary12Font
        colorCollectionView.onColorSelected = { [weak self] fontColor in
            self?.bulletSettings?.fontColor = fontColor
            self?.notifySettingsChanged()
        }
        let colorRow = createRow(titleLabel: colorLabel, rightView: colorCollectionView)

        // 将所有行加入 StackView
        // 将所有行加入 StackView
        stackView.addArrangedSubview(fontSizeButtons)
        stackView.addArrangedSubview(positionButtons)
        stackView.addArrangedSubview(colorRow)
        
        addSubview(stackView)
        
        // 使用 SnapKit 设置约束
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        fontSizeButtons.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        positionButtons.snp.makeConstraints { make in
            make.height.equalTo(32)
        }

        colorRow.snp.makeConstraints { make in
            make.height.equalTo(120)
        }
        colorCollectionView.snp.makeConstraints { make in
            make.height.equalTo(120)
            make.width.equalTo(310)
        }
    }
    
    
    private func configureFontSizeButtons() {
        // 设置大字体按钮
        largeFontButton.setImage(UIImage(named: "large_font_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        largeFontButton.setImage(UIImage(named: "large_font_icon_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        largeFontButton.addTarget(self, action: #selector(fontSizeButtonTapped(_:)), for: .touchUpInside)

        // 设置小字体按钮
        smallFontButton.setImage(UIImage(named: "small_font_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        smallFontButton.setImage(UIImage(named: "small_font_icon_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        smallFontButton.addTarget(self, action: #selector(fontSizeButtonTapped(_:)), for: .touchUpInside)

        // 默认选择大字体按钮
        largeFontButton.isSelected = true
    }

    private func configurePositionButtons() {
        // 设置顶部位置按钮
        topPositionButton.setImage(UIImage(named: "top_position_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        topPositionButton.setImage(UIImage(named: "top_position_icon_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        topPositionButton.addTarget(self, action: #selector(positionButtonTapped(_:)), for: .touchUpInside)

        // 设置中部位置按钮
        middlePositionButton.setImage(UIImage(named: "middle_position_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        middlePositionButton.setImage(UIImage(named: "middle_position_icon_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        middlePositionButton.addTarget(self, action: #selector(positionButtonTapped(_:)), for: .touchUpInside)

        // 设置底部位置按钮
        bottomPositionButton.setImage(UIImage(named: "bottom_position_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        bottomPositionButton.setImage(UIImage(named: "bottom_position_icon_selected")?.withRenderingMode(.alwaysOriginal), for: .selected)
        bottomPositionButton.addTarget(self, action: #selector(positionButtonTapped(_:)), for: .touchUpInside)

        // 默认选择顶部位置按钮
        topPositionButton.isSelected = true
    }
    
    @objc private func fontSizeButtonTapped(_ sender: UIButton) {
        largeFontButton.isSelected = sender == largeFontButton
        smallFontButton.isSelected = sender == smallFontButton
        notifySettingsChanged()
    }

    @objc private func positionButtonTapped(_ sender: UIButton) {
        topPositionButton.isSelected = sender == topPositionButton
        middlePositionButton.isSelected = sender == middlePositionButton
        bottomPositionButton.isSelected = sender == bottomPositionButton
        notifySettingsChanged()
    }
    
    private func notifySettingsChanged() {
        let selectedFontSize: BulletSettings.FontSize = largeFontButton.isSelected ? .large : .small
        let selectedPosition: BulletSettings.BulletPosition = topPositionButton.isSelected ? .top : (middlePositionButton.isSelected ? .middle : .bottom)
        self.bulletSettings?.fontSize = selectedFontSize
        self.bulletSettings?.position = selectedPosition
        onSettingsChanged?(self.bulletSettings ?? BulletSettings(fontSize: selectedFontSize, position: selectedPosition, fontColor: ._022d71))
    }

    private func createRow(titleLabel: UILabel, rightViews: [UIView]) -> UIStackView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .leading
        rowStackView.spacing = 10

        rowStackView.addArrangedSubview(titleLabel)
        
        let buttonStackView = UIStackView(arrangedSubviews: rightViews)
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 10
        rowStackView.addArrangedSubview(buttonStackView)
        let spacer = UIView()
         rowStackView.addArrangedSubview(spacer)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        buttonStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)

        return rowStackView
    }
    
    private func createRow(titleLabel: UILabel, rightView: UIView) -> UIStackView {
        let rowStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .leading
        rowStackView.spacing = 10
        
        rowStackView.addArrangedSubview(titleLabel)
        rowStackView.addArrangedSubview(rightView)
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rightView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        return rowStackView
    }
}
