//
//  TrackersViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

enum FilterOperation {
    case search
    case byWeekday
}

enum TrackersState {
    case standart
    case emptyByDate
    case emptyBySearch
}

final class TrackersViewModel {
    @Observable var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateState()
        }
    }
    @Observable var state: TrackersState = .standart
    var completedTrackers: [TrackerRecord] = []
    var selectedDate = Date().onlyDate
    var lastFilterOperation: FilterOperation = .byWeekday
    var isFulfillmentAvailable = true
    
    private var currentDate = Date().onlyDate
    private var currentWeekDay: WeekDay {
        WeekDay(numberFromSunday: selectedDate.weekday)!
    }
    private lazy var trackerStore: TrackerStore = {
        let store = TrackerStore()
        store.delegate = self
        return store
    }()
    private lazy var trackerCategoryStore = TrackerCategoryStore()
    private lazy var trackerRecordStore = TrackerRecordStore()
    private var categories: [TrackerCategory] = [] {
        didSet {
            updateVisibleCategoriesByDate()
        }
    }
    
    init() {
        try? getAllCategories()
        try? getAllRecords()
    }
    
    func didChangeDate(newDate: Date) {
        selectedDate = newDate
        isFulfillmentAvailable = !selectedDate.isInFuture
        updateVisibleCategoriesByDate()
    }
    
    func didTapDoneButtonOnTracker(trackerState: TrackerState, trackerId: UUID) {
        let trackerRecord = TrackerRecord(trackerId: trackerId, date: selectedDate)
        switch trackerState {
        case .done:
            completedTrackers.removeAll { trackerRecord in
                trackerRecord.trackerId == trackerId &&
                trackerRecord.date == selectedDate
            }
            trackerRecordStore.deleteRecord(trackerRecord)
        case .notDone:
            completedTrackers.append(trackerRecord)
            _ = trackerRecordStore.createRecord(trackerRecord)
        }
    }
    
    func didSearchFor(name: String) {
        if name.isEmpty || name.isBlank {
            updateVisibleCategoriesByDate()
        } else {
            updateVisibleCategoriesByDate()
            updateVisibleCategoriesBySearch(text: name)
        }
    }
    
    func trackerViewConfiguration(for tracker: Tracker) -> TrackerViewConfiguration {
        let isDoneButtonAvailable = isFulfillmentAvailable
        let daysStreak = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isDoneToday = completedTrackers.contains { trackerRecord in
            trackerRecord.date == selectedDate &&
            trackerRecord.trackerId == tracker.id
        }
        
        return TrackerViewConfiguration(
            isDoneToday: isDoneToday,
            isDoneButtonAvailable: isDoneButtonAvailable,
            daysCount: daysStreak
        )
    }
    
    private func getAllCategories() throws {
        do {
            categories = try trackerCategoryStore.getAllCategories()
        } catch {
            throw error
        }
    }
    
    private func getAllRecords() throws {
        do {
            completedTrackers = try trackerRecordStore.allRecords()
        } catch {
            throw error
        }
    }
    
    func updateState() {
        guard visibleCategories.isEmpty else {
            state = .standart
            return
        }
        switch lastFilterOperation {
        case .search:
            state = .emptyBySearch
        case .byWeekday:
            state = .emptyByDate
        }
    }
    
    private func updateVisibleCategoriesByDate() {
        lastFilterOperation = .byWeekday
        visibleCategories = categories.filter { category in
            for tracker in category.trackers {
                if tracker.schedule.contains(currentWeekDay) { return true }
            }
            return false
        }.map { catetegory in
            let name = catetegory.name
            let trackers = catetegory.trackers.filter { $0.schedule.contains(currentWeekDay) }
            return TrackerCategory(name: name, trackers: trackers)
        }
        
    }
    
    private func updateVisibleCategoriesBySearch(text: String) {
        lastFilterOperation = .search
        visibleCategories = visibleCategories.map { category in
            let foundTrackers = category.trackers.filter { $0.name.lowercased().contains(text.lowercased()) }
            return TrackerCategory(name: category.name, trackers: foundTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    private func createTracker(settings: TrackerSettings) {
        guard
            let name = settings.name,
            let color = settings.color,
            let emoji = settings.emoji,
            let schedule = settings.schedule,
            let settingsCategoryName = settings.categoryName
        else {
            assertionFailure("Failed to create Tracker")
            return
        }
                
        let tracker = Tracker(id: settings.id, name: name, color: color, emoji: emoji, schedule: schedule)
        let category = TrackerCategory(name: settingsCategoryName, trackers: [])
        _ = trackerStore.createTracker(tracker, category: category)
    }
}

extension TrackersViewModel: TrackerStoreDelegate {
    func storeDidUpdate(_ store: TrackerStore) {
        try? getAllCategories()
    }
}

extension TrackersViewModel: NewTrackerViewControllerDelegate {
    func newTrackerViewController(_ newTrackerViewController: NewTrackerViewController, didBuildTrackerWith settings: TrackerSettings) {
        createTracker(settings: settings)
    }
}
