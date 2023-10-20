//
//  Tracker.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [WeekDay]
}

struct TrackerCategory {
    let name: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let trackerId: UUID
    let date: Date
}

enum WeekDay {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    init?(number: Int) {
        switch number {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default: return nil
        }
    }
}


