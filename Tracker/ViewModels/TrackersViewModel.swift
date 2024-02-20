//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Глеб Капустин on 20.02.2024.
//

import Foundation

protocol TrackersViewModelProtocol: ModalCreationTrackerVCDelegate {
    var currentDate: Date { get set }
    var allCategories: [TrackerCategory] { get }
    var categories: [TrackerCategory] { get }
    
    var allCategoriesBinding: Binding<[TrackerCategory]>? { get set }
    var completedTrackersBinding: Binding<(Bool, Int, TrackerCollectionViewCell)>? { get set }
    
    func setInitialStateButton(cell: TrackerCollectionViewCell, trackerItem: Tracker)
    func plusButtonTapped(cell: TrackerCollectionViewCell, indexPath: IndexPath)
    func updateCategories()
}

final class TrackersViewModel: TrackersViewModelProtocol {
    private let dateFormatter = DateFormatter()
    var currentDate: Date = Date()
    
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private (set) var allCategories: [TrackerCategory]
    private (set) var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord]
    
    var allCategoriesBinding: Binding<[TrackerCategory]>?
    var completedTrackersBinding: Binding<(Bool, Int, TrackerCollectionViewCell)>?
    
    init(
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore(),
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        
        allCategories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.trackerRecords
        updateCategories()
        dateFormatter.dateFormat = "dd.MM.yy"
    }
    
     func updateCategories(){
        categories.removeAll()
        allCategories.forEach {
            var newTrackers: [Tracker] = []
            for tracker in $0.trackers {
                if tracker.schedule.contains(where: { $0.rawValue == currentDate.dayNumberOfWeek() }) {
                    newTrackers.append(tracker)
                }
            }
            if !newTrackers.isEmpty  {
                categories.append(TrackerCategory(header: $0.header, trackers: newTrackers))
            }
        }
        
        allCategoriesBinding?(allCategories)
    }
    
  
    
    private func deleteTrackerRecord(trackerRecord: TrackerRecord) {
        let currentDateString = dateFormatter.string(from: currentDate)
        
        trackerRecordStore.deleteTrackerRecord(
            trackerRecord: trackerRecord)
        completedTrackers.removeAll(where: {$0.id == trackerRecord.id && currentDateString == dateFormatter.string(from: $0.date)})
    }
    
   private func addTrackerRecord(newTrackerRecord: TrackerRecord){
        trackerRecordStore.addTrackerRecord(trackerRecord: newTrackerRecord)
        completedTrackers.append(newTrackerRecord)
    }
    
    func plusButtonTapped(cell: TrackerCollectionViewCell, indexPath: IndexPath) {
        let trackerItem = categories[indexPath.section].trackers[indexPath.item]
        let currentDateString = dateFormatter.string(from: currentDate)
        
        var isMarked: Bool = false
        var countDayRecord = 0
        completedTrackers.forEach {
            if trackerItem.id == $0.id && currentDateString == dateFormatter.string(from: $0.date) {
                isMarked = true
            }
            if trackerItem.id == $0.id {
                countDayRecord += 1
            }
        }
        
        if isMarked {
            deleteTrackerRecord(trackerRecord: TrackerRecord(id: trackerItem.id, date: currentDate))
            countDayRecord -= 1
            
        } else {
            let newTrackerRecord = TrackerRecord(id: trackerItem.id, date: currentDate)
            addTrackerRecord(newTrackerRecord: newTrackerRecord)
            countDayRecord += 1
        }
        completedTrackersBinding?((isMarked, countDayRecord, cell))
    }
    
    func setInitialStateButton(cell: TrackerCollectionViewCell, trackerItem: Tracker){
        var isMarked: Bool = false
        var countDayRecord = 0
        completedTrackers.forEach {
            if trackerItem.id == $0.id && dateFormatter.string(from: currentDate) == dateFormatter.string(from: $0.date) {
                isMarked = true
            }
            if trackerItem.id == $0.id {
                countDayRecord += 1
            }
        }
        
        completedTrackersBinding?((!isMarked, countDayRecord, cell))
    }
}

extension TrackersViewModel: ModalCreationTrackerVCDelegate {
    func createTracker(category: TrackerCategory) {
        var isExist = false
        var trackers: [Tracker] = []
        for (index, i) in allCategories.enumerated() {
            if i.header == category.header {
                isExist = true
                trackers.append(contentsOf: i.trackers)
                trackers.append(contentsOf: category.trackers)
                
                let trackerCategory = TrackerCategory(header: i.header, trackers: trackers)
                trackerCategoryStore.updateObject(trackerCategory: trackerCategory)
                allCategories[index] = trackerCategory
            }
        }
        if !isExist {
            trackerCategoryStore.addNewTrackerCategory(category)
            allCategories.append(category)
        }
        updateCategories()
    }
}
