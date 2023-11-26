//
//  CoreDataManager.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "HabitsTracker")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {
        UIColorValueTransformer.register()
    }
    
    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func clearData() {
        let fetchRequests: [NSFetchRequest] = [
            TrackerCategoryCD.fetchRequest(),
            TrackerCD.fetchRequest(),
            TrackerRecordCD.fetchRequest()
        ]
        let deleteRequests = fetchRequests.map { NSBatchDeleteRequest(fetchRequest: $0) }
        
        do {
            for request in deleteRequests {
                try context.execute(request)
            }
            saveContext()
        } catch {
            assertionFailure("Failed to clear CoreData")
        }
    }
}
