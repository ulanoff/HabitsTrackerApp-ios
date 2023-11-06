//
//  TrackerRecordCD.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 05.11.2023.
//

import Foundation
import CoreData

public class TrackerRecordCD: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCD> {
        return NSFetchRequest<TrackerRecordCD>(entityName: "TrackerRecordCD")
    }

    @NSManaged public var date: Date?
    @NSManaged public var trackerId: UUID?
}
