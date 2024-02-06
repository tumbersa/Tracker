//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Глеб Капустин on 30.01.2024.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init(){}
    
    lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tracker")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as? NSError {
                
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext = {
        shared.persistantContainer.viewContext
    }()
    
    
    func saveContext(){
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
