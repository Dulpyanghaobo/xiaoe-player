//
//  CustomSlider.swift
//  AntPlayerH
//
//  Created by i564407 on 8/17/24.
//

import UIKit

class CustomSlider: UISlider {
    // 扩大点击区域
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let bounds = self.bounds.insetBy(dx: -10, dy: -10) // 增加的点击区域大小
        return bounds.contains(point)
    }
}

