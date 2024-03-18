//
//  AnalyticsItems.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.03.2024.
//

import Foundation

//Не отправляются для событий open и close
enum AnalyticsItems {
    static let addTrack = "add_track"
    static let track = "track"
    static let filter = "filter"
    static let edit = "edit"
    static let delete = "delete"
}
