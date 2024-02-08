//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Глеб Капустин on 08.02.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        request.returnsObjectsAsFaults = false
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil, cacheName: nil)
        
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    override init(){
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContaine.viewContext
    }
    
    var trackerRecords: [TrackerRecord] {
        let objects = (fetchedResultsController.fetchedObjects) ?? []
        var trackerRecords: [TrackerRecord] = []
        objects.forEach {
            if let id = $0.id, let date = $0.date {
                trackerRecords.append(TrackerRecord(id:  id, date: date))
            }
        }
        return trackerRecords
    }
    
    func addTrackerRecord(trackerRecord: TrackerRecord){
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingTrackerRecord(trackerRecordCoreData: trackerRecordCoreData, trackerRecord: trackerRecord)
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
    }
    
    private func updateExistingTrackerRecord(trackerRecordCoreData: TrackerRecordCoreData, trackerRecord: TrackerRecord){
        trackerRecordCoreData.id = trackerRecord.id
        trackerRecordCoreData.date = trackerRecord.date
    }
    
    func deleteTrackerRecord(trackerRecord: TrackerRecord){
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND date == %@", trackerRecord.id as CVarArg, trackerRecord.date as CVarArg)
        if let trackerRecordCoreData = (try? context.fetch(request))?.first {
            context.delete(trackerRecordCoreData)
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
    }
    
    private func clearDB() {
        // create the delete request for the specified entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // get reference to the persistent container
        let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContaine

        // perform the delete
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
    }
}

