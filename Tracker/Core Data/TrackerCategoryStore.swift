//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.02.2024.
//

import CoreData
import UIKit

enum TrackerUpdateType {
    case insert
    case edit
    case update
    case delete
}

struct TrackerCategoryStoreUpdate {
    struct Move: Hashable {
        let oldIndex: Int
        let newIndex: Int
    }
    let insertedIndexes: IndexSet
    let updatedIndexes: IndexSet
    let deletedIndexes: IndexSet
    let movedIndexes: Set<Move>
}

final class TrackerCategoryStore: NSObject {
    
    static let shared = TrackerCategoryStore()
    
    
    private var typeUpdate: TrackerUpdateType?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    private var movedIndexes: Set<TrackerCategoryStoreUpdate.Move>?
    
    private let context: NSManagedObjectContext
    private let mapper: TrackerCategoryStoreMapper
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private override init() {
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        mapper = TrackerStore()
        super.init()
    }
    
    var headers: [String] {
        let objects = fetchedResultsController.fetchedObjects
        var headers: [String] = []
        objects?.forEach{ headers.append($0.header ?? "") }
        return headers
    }
    
    var categories: [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        var categories: [TrackerCategory] = []
        let objects: [TrackerCategoryCoreData] = (try? context.fetch(request)) ?? []
        
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
    
    func updateHeader(oldValue: String, newValue: String){
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", oldValue)
        if let trackerCategoryCoreData = try? context.fetch(request).first {
            trackerCategoryCoreData.header = newValue
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
        }
    }
    
    func addHeader(headerCategory: String){
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.header = headerCategory
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
    }
    
    func deleteCategory(headerCategory: String){
        let objects = fetchedResultsController.fetchedObjects
        objects?.forEach { trackerCatecoryCoreData in
            if let header = trackerCatecoryCoreData.header,
               header == headerCategory {
                context.delete(trackerCatecoryCoreData)
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
        typeUpdate = .insert
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if let type = typeUpdate {
            delegate?.didUpdate(update: TrackerCategoryStoreUpdate(
                insertedIndexes: insertedIndexes  ?? IndexSet(),
                updatedIndexes: updatedIndexes ?? IndexSet(),
                deletedIndexes: deletedIndexes  ?? IndexSet(),
                movedIndexes: movedIndexes ?? Set<TrackerCategoryStoreUpdate.Move>()),
                type: type)
        }
        
        insertedIndexes = nil
        deletedIndexes = nil
        movedIndexes = nil
        updatedIndexes = nil
        
        if delegate != nil {
            NotificationCenter.default.post(
                name: NSNotification.Name.didChangeTrackers,
                object: self, userInfo: ["Type" : typeUpdate as Any])
        }
        typeUpdate = nil
    }

    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                guard let newIndexPath else { return }
                insertedIndexes?.insert(newIndexPath.row)
                typeUpdate = .insert
            case .delete:
                guard let indexPath else { return }
                deletedIndexes?.insert(indexPath.row)
                typeUpdate = .delete
            case .update:
                guard let indexPath else { return }
                updatedIndexes?.insert(indexPath.row)
                typeUpdate = .update
            case .move:
                guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { return }
                movedIndexes?.insert(.init(oldIndex: oldIndexPath.item, newIndex: newIndexPath.item))
                typeUpdate = .edit
            default:
                break
            }
    }
}

