//
//  HabitsTrackerTests.swift
//  HabitsTrackerTests
//
//  Created by Andrey Ulanov on 22.11.2023.
//

import XCTest
import SnapshotTesting
@testable import HabitsTracker

final class HabitsTrackerTests: XCTestCase {
    
    // Before starting tests, change "mockMode" property in AppDelegate to true 
    // to use fixed mock data from MockService
    
    private let mockService = MockService()
    
    override func setUp() {
        isRecording = false
    }
    
    func testTrackersViewController() {
        let vm = TrackersViewModel()
        let vc = TrackersViewController(viewModel: vm)
        assertSnapshot(of: vc, as: .image)
    }
    
    func testOnboardingViewController() {
        let vc = OnboardingViewController()
        assertSnapshot(of: vc, as: .image)
    }
    
    func testOnboardingPageViewController() {
        let vc = OnboardingPageViewController(text: "Test", backgroundImage: .checkmark)
        assertSnapshot(of: vc, as: .image)
    }
    
    func testFiltersViewController() {
        let delegate = FilterViewModelDelegateFake()
        let vm1 = FiltersViewModel(delegate: delegate, selectedFilter: nil)
        let vc1 = FiltersViewController(viewModel: vm1)
        let vm2 = FiltersViewModel(delegate: delegate, selectedFilter: .byWeekday)
        let vc2 = FiltersViewController(viewModel: vm2)
        assertSnapshot(of: vc1, as: .image)
        assertSnapshot(of: vc2, as: .image)
    }
    
    func testTrackerSettingsViewController() {
        let mockTracker = mockService.getMockTracker()
        let vc1 = TrackerSettingsViewController(tracker: mockTracker)
        let vc2 = TrackerSettingsViewController(trackerType: .habit)
        assertSnapshot(of: vc1, as: .image)
        assertSnapshot(of: vc2, as: .image)
    }
    
    func testSelectTypeViewController() {
        let vc = SelectTypeViewController()
        assertSnapshot(of: vc, as: .image)
    }
    
    func testCategoryNameViewController() {
        let vm = CategoryNameViewModel()
        let vc1 = CategoryNameViewController(type: .editing, categoryName: "Test", viewModel: vm)
        let vc2 = CategoryNameViewController(type: .creating, categoryName: "Test", viewModel: vm)
        assertSnapshot(of: vc1, as: .image)
        assertSnapshot(of: vc2, as: .image)
    }
    
    func testCategoriesViewController() {
        let delegate = CategoriesViewModelDelegateFake()
        let mockCategory = mockService.getMockCategories()[0]
        let vm1 = CategoriesViewModel(delegate: delegate, selectedCategory: nil)
        let vc1 = CategoriesViewController(viewModel: vm1)
        let vm2 = CategoriesViewModel(delegate: delegate, selectedCategory: mockCategory.name)
        let vc2 = CategoriesViewController(viewModel: vm2)
        assertSnapshot(of: vc1, as: .image)
        assertSnapshot(of: vc2, as: .image)
    }
    
    func testScheduleViewController() {
        let vc = ScheduleViewController(currentSchedule: [.monday, .tuesday, .thursday, .saturday])
        assertSnapshot(of: vc, as: .image)
    }
    
    func testStatisticsViewController() {
        let statsService = StatisticsService(
            trackerStore: TrackerStore.shared,
            trackerRecordStore: TrackerRecordStore.shared
        )
        let vm = StatisticsViewModel(statisticsService: statsService)
        let vc = StatisticsViewController(viewModel: vm)
        assertSnapshot(of: vc, as: .image)
    }
    
}

final class FilterViewModelDelegateFake: FiltersViewModelDelegate {
    func filtersViewModel(_ viewModel: HabitsTracker.FiltersViewModel, didSelectFilter filter: HabitsTracker.FilterOperation) {}
}

final class CategoriesViewModelDelegateFake: CategoriesViewModelDelegate {
    func categoriesViewModel(_ viewModel: HabitsTracker.CategoriesViewModel, didSelectCategory name: String) {}
}


