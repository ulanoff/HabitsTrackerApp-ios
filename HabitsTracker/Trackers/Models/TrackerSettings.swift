//
//  TrackerSettings.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.10.2023.
//

import UIKit

enum TrackerType {
    case habit
    case irregularEvent
}

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
            schedule = WeekDay.everyday
        }
    }
    
    var isReady: Bool {
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
