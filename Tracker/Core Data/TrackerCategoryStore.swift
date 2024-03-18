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
    case updateIsPinned
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
        request.predicate = NSPredicate(format: "header != %@", "Закрепленные")
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
        var categories: [TrackerCategory] = []
        
        let fetchRequestPinned = TrackerCategoryCoreData.fetchRequest()
        fetchRequestPinned.predicate = NSPredicate(format: "ANY trackers.prevCategoryName != nil")
        var objects: [TrackerCategoryCoreData] = (try? context.fetch(fetchRequestPinned)) ?? []
        
        let fetchRequestDefault = TrackerCategoryCoreData.fetchRequest()
        let sortByHeader = NSSortDescriptor(key: "header", ascending: true)
        fetchRequestDefault.predicate = NSPredicate(format: "ANY trackers.prevCategoryName = nil")
        fetchRequestDefault.sortDescriptors = [sortByHeader]
        objects.append(contentsOf: (try? context.fetch(fetchRequestDefault)) ?? [])
        
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
    
    private func updateExistingTrackerCategory(trackerCategoryCoreData: TrackerCategoryCoreData, trackerCategory: TrackerCategory, isEditTracker: Bool = false){
        
        let newTrackersCoreData = trackerCategory.trackers.map {
            mapper.trackerCoreData(from: $0, context: context)
        }
        
        let oldTrackers = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData]) ?? []
        if !isEditTracker {
            trackerCategoryCoreData.header = trackerCategory.header
            
            newTrackersCoreData.forEach {
                let uuids: [UUID?] = oldTrackers.map{ $0.id }
                if !uuids.contains($0.id) {
                    trackerCategoryCoreData.addToTrackers($0)
                    $0.trackerCategory = trackerCategoryCoreData
                }
            }
        } else {
            guard let trackerForUpdate = newTrackersCoreData.first else { return }
            oldTrackers.forEach{
                guard let oldTrackerID = $0.id, let trackerForUpdateID = trackerForUpdate.id else { return }
                if oldTrackerID == trackerForUpdateID {
                    mapper.updateExistingTracker(oldTrackerCD: $0, newTrackerCD: trackerForUpdate)
                }
                
                if trackerCategoryCoreData.header != trackerCategory.header {
                    if let trackerCD = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?
                        .filter({ $0.id == trackerForUpdateID }).first {
                        trackerCategoryCoreData.removeFromTrackers(trackerCD)
                    }
                    updateObject(trackerCategory: trackerCategory)
                }
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
    
    func pinTracker(trackerID: UUID, nameCategory: String) {
        let pinnedHeader = "Закрепленные"
        let pinnedCategoryCD = getCategoryCD(header: pinnedHeader)
        
        let requestTracker = TrackerCategoryCoreData.fetchRequest()
        requestTracker.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        let trackerCategoryCD = (try? context.fetch(requestTracker))?.first
        if let trackerCD = (trackerCategoryCD?.trackers?.allObjects as? [TrackerCoreData])?
            .filter({ $0.id == trackerID }).first {
            
            trackerCD.prevCategoryName = nameCategory
            trackerCategoryCD?.removeFromTrackers(trackerCD)
            trackerCD.trackerCategory = pinnedCategoryCD
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
            
            typeUpdate = .updateIsPinned
            postUpdate()
        }
    }
    
    private func getCategoryCD(header: String) -> TrackerCategoryCoreData {
       
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "header == %@", header)
        let categoryCD = (try? context.fetch(request))?.first
        
        if let categoryCD {
            return categoryCD
        } else {
            let newCategoryCD = TrackerCategoryCoreData(context: context)
            newCategoryCD.header = header
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
            return newCategoryCD
        }
    }
    
    func unpinTracker(trackerID: UUID) {
        let requestTracker = TrackerCategoryCoreData.fetchRequest()
        requestTracker.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        let trackerCategoryCD = (try? context.fetch(requestTracker))?.first
        if let trackerCD = (trackerCategoryCD?.trackers?.allObjects as? [TrackerCoreData])?
            .filter({ $0.id == trackerID }).first {
            
            let prevCategoryName = trackerCD.prevCategoryName ?? ""
            let prevCategoryCD = getCategoryCD(header: prevCategoryName)
            
            trackerCD.prevCategoryName = nil
            trackerCategoryCD?.removeFromTrackers(trackerCD)
            trackerCD.trackerCategory = prevCategoryCD
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
            
            typeUpdate = .updateIsPinned
            postUpdate()
        }
    }
    
    private func postUpdate(){
        NotificationCenter.default.post(
            name: NSNotification.Name.didChangeTrackers,
            object: self, userInfo: ["Type" : typeUpdate as Any])
    }
    
    func updateTracker(category: TrackerCategory) {
        guard let trackerID = category.trackers.first?.id else { return }
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        if let trackerCategoryCoreData = try? context.fetch(request).first {
            updateExistingTrackerCategory(trackerCategoryCoreData: trackerCategoryCoreData, trackerCategory: category, isEditTracker: true)
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
            typeUpdate = .update
            postUpdate()
        }
    }
    
    func deleteTracker(trackerID: UUID) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "ANY trackers.id == %@", trackerID as CVarArg)
        
        if let trackerCategoryCoreData = try? context.fetch(request).first {
            if let trackerCD = (trackerCategoryCoreData.trackers?.allObjects as? [TrackerCoreData])?
                .filter({ $0.id == trackerID }).first {
                trackerCategoryCoreData.removeFromTrackers(trackerCD)
                context.delete(trackerCD)
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
            typeUpdate = .update
            postUpdate()
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
        movedIndexes = Set<TrackerCategoryStoreUpdate.Move>()
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
           postUpdate()
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

