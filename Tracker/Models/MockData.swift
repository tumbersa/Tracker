//
//  MockData.swift
//  Tracker
//
//  Created by Глеб Капустин on 19.01.2024.
//

import Foundation

enum MockData {
    static let category: TrackerCategory = TrackerCategory(header: "Домашний уют", trackers: [
        Tracker(id: UUID(), name: "Поливать растения", color: .systemGreen, emoji: "❤️", schedule: [.thursday]),
        Tracker(id: UUID(), name: "Вынести мусор", color: .purple, emoji: "🙂", schedule: [.thursday, .friday]),
        Tracker(id: UUID(), name: "Свидания с работой", color: .blue, emoji: "🥲", schedule: [.friday])
    ])
}
