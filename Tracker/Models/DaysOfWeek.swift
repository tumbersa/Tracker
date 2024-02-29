//
//  DaysOfWeek.swift
//  Tracker
//
//  Created by Глеб Капустин on 19.01.2024.
//

import Foundation

enum DaysOfWeek: Int, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    static func getShortenedDays(days: [DaysOfWeek]) -> String {
        var returnString = ""
        for index in days.indices {
            switch days[index] {
            case .monday:
                returnString += NSLocalizedString("mondayAbbreviation", comment: "")
            case .tuesday:
                returnString += NSLocalizedString("tuesdayAbbreviation", comment: "")
            case .wednesday:
                returnString += NSLocalizedString("wednesdayAbbreviation", comment: "")
            case .thursday:
                returnString += NSLocalizedString("thursdayAbbreviation", comment: "")
            case .friday:
                returnString += NSLocalizedString("fridayAbbreviation", comment: "")
            case .saturday:
                returnString += NSLocalizedString("saturdayAbbreviation", comment: "")
            case .sunday:
                returnString += NSLocalizedString("sundayAbbreviation", comment: "")
            }
            if index != days.count - 1 {
                returnString += ", "
            }
        }
        return returnString
    }
}

