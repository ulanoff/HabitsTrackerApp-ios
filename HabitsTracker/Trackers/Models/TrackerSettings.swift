//
//  TrackerSettings.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import UIKit

struct TrackerSettings {
    var trackerType: TrackerType
    var id = UUID()
    var name: String?
    var color: UIColor?
    var emoji: String?
    var schedule: [WeekDay]?
    var categoryName: String?
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        if trackerType == .irregularEvent {
            schedule = WeekDay.allCases
        }
    }
    
    init(for tracker: Tracker, trackerCategoryStore: TrackerCategoryStore) {
        trackerType = tracker.type
        id = tracker.id
        name = tracker.name
        color = tracker.color
        emoji = tracker.emoji
        schedule = tracker.schedule
        categoryName = trackerCategoryStore.getCategoryNameFor(tracker: tracker)
    }
    
    var isValid: Bool {
        if name != nil &&
            color != nil &&
            emoji != nil &&
            schedule != nil &&
            schedule != [] &&
            categoryName != nil
        {
            return true
        } else {
            return false
        }
    }
}
