//
//  TrackerStore.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.02.2024.
//

import Foundation

import CoreData
import UIKit

protocol TrackerCategoryStoreMapper {
    func trackerCoreData(from tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker
}

enum TrackerStoreError: Error {
    case decodingError
}

final class TrackerStore: NSObject {
    
    private let daysOfWeekTransformer = DaysValueTransformer()
    private let context: NSManagedObjectContext
    
    var headerForCategory: String = ""
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let request = TrackerCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)]
        request.predicate = NSPredicate(format: "trackerCategory.header == %@", headerForCategory)
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    override init() {
        
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContaine.viewContext
        super.init()
    }
    
    var objects: [TrackerCoreData] {
        fetchedResultsController.fetchedObjects ?? []
    }
    
    
    private func updateExistingTracker(trackerCoreData: TrackerCoreData, tracker: Tracker){
        trackerCoreData.id = tracker.id
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = UIColorMarshalling.UIColorToHex(color: tracker.color)
        trackerCoreData.schedule = tracker.schedule as NSObject
    }
    

}

extension TrackerStore: TrackerCategoryStoreMapper {
    func trackerCoreData(from tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData: trackerCoreData, tracker: tracker)
        
        return trackerCoreData
    }
    
    func tracker(from trackerCoreData: TrackerCoreData) throws -> Tracker  {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let hexColor = trackerCoreData.colorHex,
              let emoji = trackerCoreData.emoji,
              let schedule = trackerCoreData.schedule as? [DaysOfWeek] else {
            throw TrackerStoreError.decodingError
        }
        
        let color = UIColorMarshalling.hexToUIColor(hex: hexColor)
        
        return Tracker(id: id, name: name, color: color, emoji: emoji, schedule: schedule)
    }
}
