//
//  Store.swift
//  Tracker
//
//  Created by Глеб Капустин on 04.02.2024.
//

import CoreData

final class Store {
    let marshalling = UIColorMarshalling()
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init(){
        self.init(context: CoreDataStack.shared.context)
    }
}
