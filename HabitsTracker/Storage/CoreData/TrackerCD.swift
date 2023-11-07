//
//  TrackerCD.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import UIKit
import CoreData

public class TrackerCD: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCD> {
        return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var schedule: [Int]?
    @NSManaged public var timestamp: Date?
    @NSManaged public var category: TrackerCategoryCD?
}
