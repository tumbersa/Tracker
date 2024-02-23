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
    private let dateFormatter = DateFormatter()
    
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
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        dateFormatter.dateFormat = "dd.MM.yy"
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
        request.predicate = NSPredicate(format: "id == %@", trackerRecord.id as CVarArg)
        (try? context.fetch(request))?.forEach { trackerRecordCoreData in
            if let trackerRecordCoreDataDate = trackerRecordCoreData.date,
                dateFormatter.string(from: trackerRecordCoreDataDate) == dateFormatter.string(from: trackerRecord.date){
                context.delete(trackerRecordCoreData)
            }
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext(context: context)
    }
    
    func clearDB() {
        // create the delete request for the specified entity
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
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

