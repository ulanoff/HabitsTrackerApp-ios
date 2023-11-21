//
//  TrackerCategoryStore.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import Foundation

enum TrackerCategoryStoreError: Error {
    case convertingError
}

final class TrackerCategoryStore: NSObject {
    private let context = CoreDataManager.shared.context
    private lazy var trackerStore = TrackerStore()
    
    func getAllCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCD.timestamp, ascending: false)
        ]
        let result = try? context.fetch(request)
        
        guard let result else {
            return []
        }
        
        do {
            let pinndedCategory = try getPinnedCategory()
            var categories = try result.map { categoryCD in
                guard
                    let name = categoryCD.name,
                    let trackersCD = categoryCD.trackers?.allObjects as? [TrackerCD]
                else {
                    throw TrackerCategoryStoreError.convertingError
                }
                var trackers: [Tracker] = []
                trackers = try trackersCD.sorted { lhs, rhs in
                    guard
                        let lhsTimestamp = lhs.timestamp,
                        let rhsTimestamp = rhs.timestamp
                    else {
                        throw TrackerStoreError.convertingError
                    }
                    return lhsTimestamp.compare(rhsTimestamp) == .orderedDescending
                }.map {
                    do {
                        return try trackerStore.trackerViewModel(from: $0)
                    } catch {
                        throw TrackerCategoryStoreError.convertingError
                    }
                }.filter { tracker in
                    return !pinndedCategory.trackers.contains(tracker)
                }
                
                return TrackerCategory(name: name, trackers: trackers)
            }
            categories.insert(pinndedCategory, at: 0)
            return categories
        } catch {
            throw error
        }
    }
    
    func getAllCategoriesNames() -> [String] {
        let request = TrackerCategoryCD.fetchRequest()
        if let result = try? context.fetch(request) {
            return result.map { $0.name ?? "" }
        } else {
            return []
        }
    }
    
    func getCategoryNameFor(tracker: Tracker) -> String? {
        let request = TrackerCategoryCD.fetchRequest()
        if let result = try? context.fetch(request) {
            let trackerCategory = result.filter {
                guard let category = try? trackerCategoryViewModel(from: $0) else {
                    return false
                }
                return category.trackers.contains(tracker)
            }.first
            return trackerCategory?.name
        } else {
            return nil
        }
    }
    
    private func getPinnedCategory() throws -> TrackerCategory {
        let name = NSLocalizedString("defaultCategory.pinned", comment: "")
        let request = TrackerCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = YES",
            #keyPath(TrackerCD.isPinned)
        )
        guard let result = try? context.fetch(request) else {
            return TrackerCategory(name: name, trackers: [])
        }
        do {
            let trackers = try result.map {
                try trackerStore.trackerViewModel(from: $0)
            }
            return TrackerCategory(name: name, trackers: trackers)
        } catch {
            throw TrackerCategoryStoreError.convertingError
        }
    }
    
    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
    
    func findCategory(_ category: TrackerCategory) -> TrackerCategoryCD? {
        let request = TrackerCategoryCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@",
            #keyPath(TrackerCategoryCD.name),
            category.name
        )
        let result = try? context.fetch(request)
        
        if let category = result?.first {
            return category
        } else {
            return nil
        }
    }
    
    func createCategory(_ category: TrackerCategory) -> TrackerCategoryCD {
        let categoryCD = TrackerCategoryCD(context: context)
        categoryCD.name = category.name
        categoryCD.trackers = []
        categoryCD.timestamp = Date()
        
        saveContext()
        return categoryCD
    }
    
    func updateCategoryInfo(_ category: TrackerCategory, to newCategory: TrackerCategory) {
        if let category = findCategory(category) {
            category.name = newCategory.name
            saveContext()
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) {
        if let categoryCD = findCategory(category) {
            context.delete(categoryCD)
            saveContext()
        }
    }
    
    func trackerCategoryViewModel(from trackerCategoryCD: TrackerCategoryCD) throws -> TrackerCategory {
        guard
            let name = trackerCategoryCD.name,
            let trackersCD = trackerCategoryCD.trackers?.allObjects as? [TrackerCD]
        else {
            throw TrackerCategoryStoreError.convertingError
        }
        
        do {
            let trackers = try trackersCD.map {
                try trackerStore.trackerViewModel(from: $0)
            }
            return TrackerCategory(name: name, trackers: trackers)
        } catch {
            throw TrackerCategoryStoreError.convertingError
        }
    }
}
