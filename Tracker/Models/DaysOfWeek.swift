//
//  DaysOfWeek.swift
//  Tracker
//
//  Created by Глеб Капустин on 19.01.2024.
//

import Foundation

enum DaysOfWeek: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    static func printDaysMessage(_ days: Int) -> String {
        
        if days == 0 {
            return "0 дней"
        } else if days == 1 {
            return "1 день"
        } else if days >= 2 && days <= 4 {
            return "\(days) дня"
        } else if days >= 5 && days <= 20 {
            return "\(days) дней"
        } else if days % 10 == 1 {
            return "\(days) день"
        } else if days % 10 >= 2 && days % 10 <= 4 {
            return "\(days) дня"
        } else {
            return "\(days) дней"
        }
    }
    
    static func getShortenedDays(days: [DaysOfWeek]) -> String {
        var returnString = ""
        for index in days.indices {
            switch days[index] {
            case .monday:
                returnString += "Пн"
            case .tuesday:
                returnString += "Вт"
            case .wednesday:
                returnString += "Ср"
            case .thursday:
                returnString += "Чт"
            case .friday:
                returnString += "Пт"
            case .saturday:
                returnString += "Сб"
            case .sunday:
                returnString += "Вс"
            }
            if index != days.count - 1 {
                returnString += ", "
            }
        }
        return returnString
    }
}
