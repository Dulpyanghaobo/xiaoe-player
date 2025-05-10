//
//  CustomPopupView.swift
//  AntPlayerH
//
//  Created by i564407 on 8/3/24.
//

import UIKit

class CustomPopupView: UIView {

    enum Position {
        case top, center, bottom
    }

    private var contentView: UIView
    private var position: Position
    private var backgroundView: UIView

    init(contentView: UIView, position: Position) {
        self.contentView = contentView
        self.position = position
        self.backgroundView = UIView()
        super.init(frame: UIScreen.main.bounds)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundView.frame = bounds
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
        backgroundView.alpha = 0
        addSubview(backgroundView)
        
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        addSubview(contentView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        backgroundView.addGestureRecognizer(tapGesture)
    }

    func show(in viewController: UIViewController) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        keyWindow.addSubview(self)
        
        layoutContentView()
        animateShow()
    }

    private func layoutContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        switch position {
        case .top:
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: topAnchor, constant: 50),
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.widthAnchor.constraint(equalToConstant: 300),
                contentView.heightAnchor.constraint(equalToConstant: 200)
            ])
        case .center:
            NSLayoutConstraint.activate([
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
                contentView.widthAnchor.constraint(equalToConstant: 300),
                contentView.heightAnchor.constraint(equalToConstant: 200)
            ])
        case .bottom:
            NSLayoutConstraint.activate([
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
                contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
                contentView.widthAnchor.constraint(equalToConstant: 300),
                contentView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
    }

    private func animateShow() {
        contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1
            self.contentView.transform = .identity
        })
    }

    @objc private func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            self.contentView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}
