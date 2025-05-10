//
//  ToastUtil.swift
//  AntPlayerH
//
//  Created by i564407 on 7/18/24.
//

import Foundation
import UIKit

class ToastUtil: NSObject {
    
    static let shared = ToastUtil()
    
    struct ToastOptions {
        var duration: TimeInterval = 2.5
        var backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.6)
        var textColor: UIColor = .white
        var font: UIFont = UIFont.systemFont(ofSize: 14)
        var cornerRadius: CGFloat = 10
        var position: ToastPosition = .bottom
    }
    
    enum ToastPosition {
        case top, center, bottom
    }
    
    func showToast(_ message: String, options: ToastOptions = ToastOptions(), completion: (() -> Void)? = nil) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = options.backgroundColor
        toastLabel.textColor = options.textColor
        toastLabel.textAlignment = .center
        toastLabel.font = options.font
        toastLabel.text = message
        toastLabel.alpha = 1
        toastLabel.layer.cornerRadius = options.cornerRadius
        toastLabel.clipsToBounds = true
        
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        window?.addSubview(toastLabel)
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var positionConstraint: NSLayoutConstraint
        switch options.position {
        case .top:
            positionConstraint = toastLabel.topAnchor.constraint(equalTo: window!.safeAreaLayoutGuide.topAnchor, constant: 50)
        case .center:
            positionConstraint = toastLabel.centerYAnchor.constraint(equalTo: window!.centerYAnchor)
        case .bottom:
            positionConstraint = toastLabel.bottomAnchor.constraint(equalTo: window!.safeAreaLayoutGuide.bottomAnchor, constant: -50)
        }
        
        NSLayoutConstraint.activate([
            positionConstraint,
            toastLabel.leadingAnchor.constraint(equalTo: window!.leadingAnchor, constant: 20),
            toastLabel.trailingAnchor.constraint(equalTo: window!.trailingAnchor, constant: -20),
            toastLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: options.duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
                completion?()
            })
        })
    }
}
