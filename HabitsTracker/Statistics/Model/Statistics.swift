//
//  Statistics.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import Foundation

struct Statistics {
    let bestStreak: Int
    let perfectDays: Int
    let trackersCompleted: Int
    let averageCompletions: Int
    
    var isEmpty: Bool {
        bestStreak <= 0 &&
        perfectDays <= 0 &&
        trackersCompleted <= 0 &&
        averageCompletions <= 0
    }
}
