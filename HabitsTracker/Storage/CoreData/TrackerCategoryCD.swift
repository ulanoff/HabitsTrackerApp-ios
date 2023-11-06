//
//  TrackerCategoryCD.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import Foundation
import CoreData

public class TrackerCategoryCD: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCD> {
        return NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
    }

    @NSManaged public var name: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var trackers: NSSet?
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCD {

    @objc(addTrackersObject:)
    @NSManaged public func addToTrackers(_ value: TrackerCD)

    @objc(removeTrackersObject:)
    @NSManaged public func removeFromTrackers(_ value: TrackerCD)

    @objc(addTrackers:)
    @NSManaged public func addToTrackers(_ values: NSSet)

    @objc(removeTrackers:)
    @NSManaged public func removeFromTrackers(_ values: NSSet)

}
