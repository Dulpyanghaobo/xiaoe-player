//
//  Double+Exension.swift
//  AntPlayerH
//
//  Created by i564407 on 7/30/24.
//

import Foundation
extension Double {
    func formattedTime() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        
        let formattedString = formatter.string(from: self) ?? "00:00:00"
        return formattedString
    }
}
