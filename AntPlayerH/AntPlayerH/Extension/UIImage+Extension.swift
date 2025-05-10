//
//  UIImage+Extension.swift
//  task_management_tool
//
//  Created by i564407 on 4/18/24.
//

import SwiftUI

extension UIImage {
    static func gradientImage(with bounds: CGRect, colors: [CGColor], locations: [NSNumber], startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        UIGraphicsBeginImageContextWithOptions(gradient.bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        gradient.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    func resized(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}

