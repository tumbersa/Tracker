//
//  Tracker.swift
//  Tracker
//
//  Created by Глеб Капустин on 09.01.2024.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [DaysOfWeek]?
}

enum DaysOfWeek {
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    case allDays
}
