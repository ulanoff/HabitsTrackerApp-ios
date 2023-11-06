//
//  TrackerStore.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import Foundation
import CoreData

enum TrackerStoreError: Error {
    case convertingError
}

protocol TrackerStoreDelegate: AnyObject {
    func storeDidUpdate(_ store: TrackerStore)
}

final class TrackerStore: NSObject {
    private let context = CoreDataManager.shared.context
    private lazy var trackerCategoryStore = TrackerCategoryStore()
    private var fetchedResultsController: NSFetchedResultsController<TrackerCD>!
    
    override init() {
        super.init()
        let fetchRequest = TrackerCD.fetchRequest()
        let timestampSortDescriptor = NSSortDescriptor(keyPath: \TrackerCD.timestamp, ascending: true)
        let categoryNameSortDescriptor = NSSortDescriptor(keyPath: \TrackerCD.category?.name, ascending: true)
        fetchRequest.sortDescriptors = [
            timestampSortDescriptor,
            categoryNameSortDescriptor
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCD.category.name),
            cacheName: nil
        )
        controller.delegate = self
        fetchedResultsController = controller
        do {
            try controller.performFetch()
        } catch {
            assertionFailure("Failed to fetch entities: \(error)")
        }
    }
    
    weak var delegate: TrackerStoreDelegate?
    
    var trackers: [TrackerCD] {
        return fetchedResultsController.fetchedObjects!
    }
    
    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    func findTracker(_ tracker: Tracker) -> TrackerCD? {
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            (\TrackerCD.id)._kvcKeyPathString!,
            tracker.id as CVarArg
        )
        let result = try? context.fetch(request)
        
        if let trackerCD = result?.first {
            return trackerCD
        } else {
            return nil
        }
    }
    
    func createTracker(_ tracker: Tracker, category: TrackerCategory) -> TrackerCD {
        let trackerCD = TrackerCD(context: context)
        trackerCD.name = tracker.name
        trackerCD.color = tracker.color
        trackerCD.emoji = tracker.emoji
        trackerCD.id = tracker.id
        trackerCD.schedule = coreDataSchedule(from: tracker.schedule)
        trackerCD.timestamp = Date()
        
        if let categoryCD = trackerCategoryStore.findCategory(category) {
            categoryCD.addToTrackers(trackerCD)
        } else {
            let categoryCD = trackerCategoryStore.createCategory(category)
            categoryCD.addToTrackers(trackerCD)
        }
        
        saveContext()
        return trackerCD
    }
    
    func deleteTracker(_ tracker: Tracker) {
        if let tracker = findTracker(tracker) {
            context.delete(tracker)
            saveContext()
        }
    }
    
    func coreDataSchedule(from schedule: [WeekDay]) -> [Int] {
        schedule.map { $0.rawValue }
    }
    
    func viewModelSchedule(from schedule: [Int]) -> [WeekDay]? {
        var weekDays: [WeekDay] = []
        for dayNumber in schedule {
            if let weekDay = WeekDay(rawValue: dayNumber) {
                weekDays.append(weekDay)
            } else {
                return nil
            }
        }
        
        return weekDays
    }
    
    func trackerViewModel(from trackerCD: TrackerCD) throws -> Tracker {
        guard
            let name = trackerCD.name,
            let id = trackerCD.id,
            let emoji = trackerCD.emoji,
            let color = trackerCD.color,
            let cdSchedule = trackerCD.schedule,
            let schedule = viewModelSchedule(from: cdSchedule)
        else {
            throw TrackerStoreError.convertingError
        }
        
        return Tracker(id: id,
                       name: name,
                       color: color,
                       emoji: emoji,
                       schedule: schedule)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeDidUpdate(self)
    }
}