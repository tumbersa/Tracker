//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.02.2024.
//

import CoreData
import UIKit

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private let mapper: TrackerCategoryStoreMapper
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    override init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContaine.viewContext
        mapper = TrackerStore()
        super.init()
    }
    
    var categories: [TrackerCategory] {
        var categories: [TrackerCategory] = []
        let objects = fetchedResultsController.fetchedObjects ?? []
        
        objects.forEach{ trackerCategoryCoreData in
            let header = trackerCategoryCoreData.header ?? ""
            var trackers: [Tracker] = []
        
            if let trackersCoreData = trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData] {
                trackersCoreData.forEach { trackerCoreData in
                    if let newTracker = try? mapper.tracker(from: trackerCoreData) {
                        trackers.append(newTracker)
                    }
                }
                
                categories.append(TrackerCategory(header: header, trackers: trackers))
            }
        }
    
        return categories
    }
    
    func addNewTrackerCategory(_ trackerCategory: TrackerCategory) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        updateExistingTrackerCategory(trackerCategoryCoreData: trackerCategoryCoreData, trackerCategory: trackerCategory)
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
    }
    
    private func updateExistingTrackerCategory(trackerCategoryCoreData: TrackerCategoryCoreData, trackerCategory: TrackerCategory){
        trackerCategoryCoreData.header = trackerCategory.header
        
        let trackersCoreData =  trackerCategory.trackers.map {
            mapper.trackerCoreData(from: $0, context: context)
        }
        
        let oldTrackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData]) ?? []
        trackersCoreData.forEach {
            let uuids: [UUID?] = oldTrackers.map{ $0.id }
            if !uuids.contains($0.id) {
                trackerCategoryCoreData.addToTrackers($0)
                $0.trackerCategory = trackerCategoryCoreData
            }
        }
    }
    
    func updateObject(trackerCategory: TrackerCategory) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", trackerCategory.header)
        if let trackerCategoryCoreData = try? context.fetch(request).first {
            updateExistingTrackerCategory(trackerCategoryCoreData: trackerCategoryCoreData, trackerCategory: trackerCategory)
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
        }
    }
    
     func clearDB() {
        // create the delete request for the specified entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // get reference to the persistent container

        // perform the delete
        do {
            try context.execute(deleteRequest)
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
        } catch {
            print(error.localizedDescription)
        }
    }
}


