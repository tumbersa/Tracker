//
//  TrackersViewModel.swift
//  Tracker
//
//  Created by Глеб Капустин on 20.02.2024.
//

import Foundation

protocol TrackersViewModelProtocol: ModalCreationTrackerVCDelegate {
    var currentDate: Date { get set }
    var allTrackerCategories: [TrackerCategory] { get }
    var visibleTrackerCategories: [TrackerCategory] { get }
    
    var allTrackerCategoriesBinding: Binding<[TrackerCategory]>? { get set }
    var completedTrackersBinding: Binding<(Bool, Int, SomeData)>? { get set }
    var pinBinding: Binding<IndexPath>? { get set }
    
    func setInitialStateButton(someDataForBinding: SomeData, trackerItem: Tracker)
    func plusButtonTapped(someDataForBinding: SomeData, indexPath: IndexPath)
    func updateTrackers()
    func pinTracker(trackerID: UUID, nameCategory: String, indexPath: IndexPath)
    func unpinTracker(trackerID: UUID, indexPath: IndexPath)
}

final class TrackersViewModel: TrackersViewModelProtocol {
    private let dateFormatter = DateFormatter()
    var currentDate: Date = Date()
    private var indexPathForPin: IndexPath = IndexPath()
    
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    private var pinnedTrackersID: [UUID] = []
    private (set) var allTrackerCategories: [TrackerCategory]
    private (set) var visibleTrackerCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord]
    
    var allTrackerCategoriesBinding: Binding<[TrackerCategory]>?
    var completedTrackersBinding: Binding<(Bool, Int, SomeData)>?
    var pinBinding: Binding<IndexPath>?
    
    init(
        trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore.shared,
        trackerRecordStore: TrackerRecordStore = TrackerRecordStore()
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        
        allTrackerCategories = trackerCategoryStore.categories
        completedTrackers = trackerRecordStore.trackerRecords
        dateFormatter.dateFormat = "dd.MM.yy"
        
        configureObserver()
        
        updateTrackers()
        //trackerCategoryStore.clearDB()
        //trackerRecordStore.clearDB()
        //trackerCategoryStore.addNewTrackerCategory(MockData.category)
    }
    
    private func configureObserver(){
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.didChangeTrackers,
            object: nil, queue: .main) { [weak self] notification in
                guard let self else { return }
                if let dict = notification.userInfo as? [String : TrackerUpdateType],
                   let type = dict["Type"],
                   !(type == .insert) {
                    if type == .updateIsPinned {
                        pinBinding?(indexPathForPin)
                    }
                    allTrackerCategories = trackerCategoryStore.categories
                    updateTrackers()
                }
            }
    }
    
    func updateTrackers(){
        visibleTrackerCategories.removeAll()
        allTrackerCategories.forEach {
            var newTrackers: [Tracker] = []
            for tracker in $0.trackers {
                if tracker.schedule.contains(where: { $0.rawValue == currentDate.dayNumberOfWeek() }) {
                    newTrackers.append(tracker)
                }
            }
            if !newTrackers.isEmpty  {
                visibleTrackerCategories.append(TrackerCategory(header: $0.header, trackers: newTrackers))
            }
        }
        
        allTrackerCategoriesBinding?(allTrackerCategories)
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
    
    func plusButtonTapped(someDataForBinding: SomeData, indexPath: IndexPath) {
        let trackerItem = visibleTrackerCategories[indexPath.section].trackers[indexPath.item]
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
        completedTrackersBinding?((isMarked, countDayRecord, someDataForBinding))
    }
    
    func setInitialStateButton(someDataForBinding: SomeData, trackerItem: Tracker){
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
        
        completedTrackersBinding?((!isMarked, countDayRecord, someDataForBinding))
    }
    
    func pinTracker(trackerID: UUID, nameCategory: String, indexPath: IndexPath) {
        indexPathForPin = indexPath
        trackerCategoryStore.pinTracker(trackerID: trackerID, nameCategory: nameCategory)
    }
    
    func unpinTracker(trackerID: UUID, indexPath: IndexPath){
        indexPathForPin = indexPath
        trackerCategoryStore.unpinTracker(trackerID: trackerID)
    }
    
}

extension TrackersViewModel: ModalCreationTrackerVCDelegate {
    func createTracker(category: TrackerCategory) {
        
        var trackers: [Tracker] = []
        allTrackerCategories = trackerCategoryStore.categories
        for (index, i) in allTrackerCategories.enumerated() {
            if i.header == category.header {
                
                trackers.append(contentsOf: i.trackers)
                trackers.append(contentsOf: category.trackers)
                
                let trackerCategory = TrackerCategory(header: i.header, trackers: trackers)
                trackerCategoryStore.updateObject(trackerCategory: trackerCategory)
                allTrackerCategories[index] = trackerCategory
            }
        }
        updateTrackers()
    }
}
