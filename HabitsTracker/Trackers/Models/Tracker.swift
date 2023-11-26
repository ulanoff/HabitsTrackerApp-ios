//
//  Tracker.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

enum TrackerType: Int {
    case habit = 1
    case irregularEvent
}

struct Tracker: Equatable {
    let id: UUID
    let isPinned: Bool
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
    let type: TrackerType
    
    var records: Int {
        let trackerRecordStore = TrackerRecordStore.shared
        return trackerRecordStore.recordsFor(trackerID: id)
    }
    
    var pinToggled: Tracker {
        Tracker(
            id: id,
            isPinned: !isPinned,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            type: type
        )
    }

    func updated(with settings: TrackerSettings) -> Tracker {
        Tracker(
            id: id, 
            isPinned: isPinned,
            name: settings.name ?? name,
            color: settings.color ?? color,
            emoji: settings.emoji ?? emoji,
            schedule: settings.schedule ?? schedule,
            type: type
        )
    }
    
    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        lhs.id == rhs.id
    }
}

struct TrackerCategory: Equatable {
    let name: String
    let trackers: [Tracker]
    
    static func == (lhs: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lhs.name == rhs.name
    }
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}
