//
//  TrackersViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 12.11.2023.
//

import Foundation

enum TrackersState {
    case standart
    case filtersEnabled
    case emptyByDefault
    case emptyBySearch
    case emptyByFilter
}

struct TrackerIndex {
    let categoryIndex: Int
    let trackerIndex: Int
}

final class TrackersViewModel {
    @Observable var visibleCategories: [TrackerCategory] = [] {
        didSet {
            updateState()
        }
    }
    @Observable var state: TrackersState = .standart
    var completedTrackers: [TrackerRecord] = []
    var selectedFilterOperation: FilterOperation = .byWeekday {
        didSet {
            print(selectedFilterOperation)
        }
    }
    var lastFilterOperation: FilterOperation = .byWeekday
    var isFulfillmentAvailable = true
    private var currentDate = Date().onlyDate
    private var currentWeekDay: WeekDay {
        WeekDay(numberFromSunday: currentDate.weekday)!
    }
    @Observable var selectedDate = Date().onlyDate
    private var selectedWeekDay: WeekDay {
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
            filterBy(filterOperation: selectedFilterOperation)
        }
    }
    
    init() {
        try? getAllCategories()
        try? getAllRecords()
    }
    
    func didChangeDate(newDate: Date) {
        isFulfillmentAvailable = !newDate.isInFuture
        
        if 
            selectedFilterOperation == .byCompleteness ||
            selectedFilterOperation == .byNotCompleteness
        {
            selectedDate = newDate
            filterBy(filterOperation: selectedFilterOperation)
            return
        }
        
        selectedDate = newDate
        selectedFilterOperation = .byWeekday
        filterByWeekday()
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
            filterBy(filterOperation: selectedFilterOperation)
        } else {
            filterBy(filterOperation: selectedFilterOperation)
            filterBySearch(text: name)
        }
    }
    
    func didDeleteTrackerAt(index: TrackerIndex) {
        let tracker = visibleCategories[index.categoryIndex].trackers[index.trackerIndex]
        trackerStore.deleteTracker(tracker)
    }
    
    func didPinOrUnpinTracker(index: TrackerIndex) {
        
        let tracker = visibleCategories[index.categoryIndex].trackers[index.trackerIndex]
        let pinnedTracker = tracker.pinToggled
        trackerStore.updateTracker(tracker, to: pinnedTracker)
    }
    
    func trackerForEdit(at index: TrackerIndex) -> Tracker {
        visibleCategories[index.categoryIndex].trackers[index.trackerIndex]
    }
    
    func trackerViewConfiguration(for tracker: Tracker) -> TrackerViewConfiguration {
        let isDoneButtonAvailable = isFulfillmentAvailable && tracker.schedule.contains(selectedWeekDay)
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
    
    func isTrackerPinnedAt(index: TrackerIndex) -> Bool {
        visibleCategories[index.categoryIndex].trackers[index.trackerIndex].isPinned
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
            if 
                selectedFilterOperation == .byCompleteness ||
                selectedFilterOperation == .byNotCompleteness 
            {
                state = .filtersEnabled
            } else {
                state = .standart
            }
            return
        }
        
        switch lastFilterOperation {
        case .search:
            state = .emptyBySearch
        case .byWeekday:
            state = .emptyByDefault
        case .byToday:
            state = .emptyByDefault
        case .byCompleteness:
            state = .emptyByFilter
        case .byNotCompleteness:
            state = .emptyByFilter
        }
    }
    
    private func filterBy(filterOperation: FilterOperation) {
        filterByWeekday()
        switch filterOperation {
        case .byToday:
            filterByToday()
        case .byWeekday:
            filterByWeekday()
        case .byCompleteness:
            filterByCompleteness()
        case .byNotCompleteness:
            filterByNotCompleteness()
        case .search:
            return
        }
    }
    
    private func filterByWeekday() {
        lastFilterOperation = .byWeekday
        visibleCategories = categories.filter { category in
            for tracker in category.trackers {
                if tracker.schedule.contains(selectedWeekDay) { return true }
            }
            return false
        }.map { catetegory in
            let name = catetegory.name
            let trackers = catetegory.trackers.filter { $0.schedule.contains(selectedWeekDay) }
            return TrackerCategory(name: name, trackers: trackers)
        }
        
    }
    
    private func filterByToday() {
        lastFilterOperation = .byToday
        selectedDate = currentDate
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
    
    private func filterBySearch(text: String) {
        lastFilterOperation = .search
        visibleCategories = visibleCategories.map { category in
            let foundTrackers = category.trackers.filter { $0.name.lowercased().contains(text.lowercased()) }
            return TrackerCategory(name: category.name, trackers: foundTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    private func filterByCompleteness() {
        lastFilterOperation = .byCompleteness
        visibleCategories = visibleCategories.map { category in
            let foundTrackers = category.trackers.filter { tracker in
                var isCompleted = false
                completedTrackers.forEach {
                    if tracker.id == $0.trackerId &&
                       $0.date == selectedDate
                    {
                        isCompleted = true
                        return
                    }
                }
                return isCompleted
            }
            return TrackerCategory(name: category.name, trackers: foundTrackers)
        }.filter { !$0.trackers.isEmpty }
    }
    
    private func filterByNotCompleteness() {
        lastFilterOperation = .byNotCompleteness
        visibleCategories = visibleCategories.map { category in
            let foundTrackers = category.trackers.filter { tracker in
                var isCompleted = true
                completedTrackers.forEach {
                    if tracker.id == $0.trackerId &&
                       $0.date == selectedDate
                    {
                        isCompleted = false
                        return
                    }
                }
                return isCompleted
            }
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
                
        let tracker = Tracker(
            id: settings.id,
            isPinned: false,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule,
            type: settings.trackerType
        )
        let category = TrackerCategory(name: settingsCategoryName, trackers: [])
        _ = trackerStore.createTracker(tracker, category: category)
    }
    
    private func updateTracker(old: Tracker, new: Tracker) {
        trackerStore.updateTracker(old, to: new)
    }
}

extension TrackersViewModel: TrackerStoreDelegate {
    func storeDidUpdate(_ store: TrackerStore) {
        try? getAllCategories()
    }
}

extension TrackersViewModel: TrackerSettingsViewControllerDelegate {
    func trackerSettingsViewController(_ trackerSettingsViewController: TrackerSettingsViewController, didEditTracker tracker: Tracker, to newTracker: Tracker) {
        updateTracker(old: tracker, new: newTracker)
    }
    
    func trackerSettingsViewController(_ trackerSettingsViewController: TrackerSettingsViewController, didCreateTrackerWith settings: TrackerSettings) {
        createTracker(settings: settings)
    }
}

extension TrackersViewModel: FiltersViewModelDelegate {
    func filtersViewModel(_ viewModel: FiltersViewModel, didSelectFilter filter: FilterOperation) {
        selectedFilterOperation = filter
        filterBy(filterOperation: filter)
    }
}
