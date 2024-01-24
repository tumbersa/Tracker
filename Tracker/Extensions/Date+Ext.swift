//
//  Date+Ext.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.01.2024.
//

import Foundation

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
