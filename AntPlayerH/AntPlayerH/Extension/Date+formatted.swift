//
//  Date+formatted.swift
//  task_management_tool
//
//  Created by i564407 on 4/24/24.
//

import Foundation

extension Date {
    func monthDayFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd"  // MMMM 是月份的完整名称，dd 是两位数字的日
        return formatter.string(from: self)
    }
}
