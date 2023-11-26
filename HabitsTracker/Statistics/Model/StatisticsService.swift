//
//  StatisticsService.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import Foundation

final class StatisticsService {
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    private var allTrackers: [Tracker]
    private var allRecords: [TrackerRecord]
    
    init(trackerStore: TrackerStore, trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        if let allTracker = try? trackerStore.getAllTrackers(),
           let allRecords = try? trackerRecordStore.getAllRecords() {
            self.allTrackers = allTracker
            self.allRecords = allRecords
        } else {
            allTrackers = []
            allRecords = []
        }
    }
    
    func getStatitics() -> Statistics {
        updateData()
        let statistics = Statistics(
            bestStreak: bestStreak(),
            perfectDays: perfectDays(),
            trackersCompleted: trackersCompleted(),
            averageCompletions: averageCompletions()
        )
        
        return statistics
    }
    
    /// "Best Streak" calculates the maximum number of consecutive days without a break across all trackers.
    private func bestStreak() -> Int {
        let trackerIDs = Set(allRecords.map { $0.trackerId })
        var currentStreak: [Date] = []
        var longestStreak: [Date] = []
        for id in trackerIDs {
            let dates = Array(Set(allRecords.filter { $0.trackerId == id}.map { $0.date }))
            let sortedDates = dates.sorted()
            for date in sortedDates {
                if let lastDate = currentStreak.last, Calendar.current.isDate(date, inSameDayAs: lastDate.addingTimeInterval(24 * 60 * 60)) {
                    currentStreak.append(date)
                } else {
                    currentStreak = [date]
                }
                if currentStreak.count > longestStreak.count {
                    longestStreak = currentStreak
                }
            }
        }
        return longestStreak.count
    }
    
    /// "Perfect Days" considers days when all planned habits have been completed.
    private func perfectDays() -> Int {
        var perfectDays = 0
        let dates = Set(allRecords.map { $0.date })
        let habits = allTrackers.filter { $0.type == .habit }
        for date in dates {
            guard let weekday = WeekDay(numberFromSunday: date.weekday) else {
                return -1
            }
            let habitsForWeekday = habits.filter { $0.schedule.contains(weekday) }
            let records = self.allRecords.filter { record in
                habitsForWeekday.contains { $0.id == record.trackerId } &&
                record.date == date
            }
            if records.count == habitsForWeekday.count {
                perfectDays += 1
            }
        }
        return perfectDays
    }
    
    /// "Trackers Completed" calculates the total number of completed habits over all time.
    private func trackersCompleted() -> Int {
        let habits = allTrackers.filter { $0.type == .habit }
        let completions = habits.reduce(0, { partialResult, habit in
            partialResult + allRecords.filter { habit.id == $0.trackerId }.count
        })
        
        return completions
    }
    
    /// "Average Completions" calculates the average number of habits completed per day.
    private func averageCompletions() -> Int {
        let dates = Set(allRecords.map { $0.date })
        let recordsCount = allRecords.count
        let daysCount = dates.count
        
        guard recordsCount != 0 && daysCount != 0 else {
            return 0
        }
        
        let result = Int(round(Double(recordsCount) / Double(daysCount)))
        return result
    }
    
    private func updateData() {
        if let allTracker = try? trackerStore.getAllTrackers(),
           let allRecords = try? trackerRecordStore.getAllRecords() {
            self.allTrackers = allTracker
            self.allRecords = allRecords
        } else {
            allTrackers = []
            allRecords = []
        }
    }
}
