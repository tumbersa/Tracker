//
//  StatisticsViewModel.swift
//  Tracker
//
//  Created by Глеб Капустин on 13.03.2024.
//

import Foundation

protocol StatisticsViewModelProtocol {
    var completedTrackersBinding: Binding<(Bool, Int?)>? { get set }
    func isEmptyFinishedTrackers()
}

final class StatisticsViewModel: StatisticsViewModelProtocol {
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private var allTrackerCategories: [TrackerCategory]
    private var completedTrackers: [TrackerRecord]
    
    var completedTrackersBinding: Binding<(Bool, Int?)>?
    
    init(
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore.shared,
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore.shared
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        
        allTrackerCategories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.trackerRecords
    }
    
    
    func isEmptyFinishedTrackers() {
        allTrackerCategories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.trackerRecords
        
        var trackers: [Tracker] = []
        allTrackerCategories.forEach { category in
            trackers.append(contentsOf: category.trackers)
        }
        
        if trackers.isEmpty {
            completedTrackersBinding?((true, nil))
        } else {
            let countOfFinishedTrackers = Set(completedTrackers.map{ $0.id }).count
            completedTrackersBinding?((false, countOfFinishedTrackers))
        }
    }
}
