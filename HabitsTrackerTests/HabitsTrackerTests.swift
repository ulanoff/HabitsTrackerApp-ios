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
        let viewModel = TrackersViewModel()
        let viewController = TrackersViewController(viewModel: viewModel)
        assertSnapshot(of: viewController, as: .image)
    }
    
    func testOnboardingViewController() {
        let viewController = OnboardingViewController()
        assertSnapshot(of: viewController, as: .image)
    }
    
    func testOnboardingPageViewController() {
        let viewController = OnboardingPageViewController(text: "Test", backgroundImage: .checkmark)
        assertSnapshot(of: viewController, as: .image)
    }
    
    func testFiltersViewController() {
        let delegate = FilterViewModelDelegateFake()
        let viewModel1 = FiltersViewModel(delegate: delegate, selectedFilter: nil)
        let viewController1 = FiltersViewController(viewModel: viewModel1)
        let viewModel2 = FiltersViewModel(delegate: delegate, selectedFilter: .byWeekday)
        let viewController2 = FiltersViewController(viewModel: viewModel2)
        assertSnapshot(of: viewController1, as: .image)
        assertSnapshot(of: viewController2, as: .image)
    }
    
    func testTrackerSettingsViewController() {
        let mockTracker = mockService.getMockTracker()
        let viewController1 = TrackerSettingsViewController(tracker: mockTracker)
        let viewController2 = TrackerSettingsViewController(trackerType: .habit)
        assertSnapshot(of: viewController1, as: .image)
        assertSnapshot(of: viewController2, as: .image)
    }
    
    func testSelectTypeViewController() {
        let viewController = SelectTypeViewController()
        assertSnapshot(of: viewController, as: .image)
    }
    
    func testCategoryNameViewController() {
        let viewModel = CategoryNameViewModel()
        let viewController1 = CategoryNameViewController(type: .editing, categoryName: "Test", viewModel: viewModel)
        let viewController2 = CategoryNameViewController(type: .creating, categoryName: "Test", viewModel: viewModel)
        assertSnapshot(of: viewController1, as: .image)
        assertSnapshot(of: viewController2, as: .image)
    }
    
    func testCategoriesViewController() {
        let delegate = CategoriesViewModelDelegateFake()
        let mockCategory = mockService.getMockCategories()[0]
        let viewModel1 = CategoriesViewModel(delegate: delegate, selectedCategory: nil)
        let viewController1 = CategoriesViewController(viewModel: viewModel1)
        let viewModel2 = CategoriesViewModel(delegate: delegate, selectedCategory: mockCategory.name)
        let viewController2 = CategoriesViewController(viewModel: viewModel2)
        assertSnapshot(of: viewController1, as: .image)
        assertSnapshot(of: viewController2, as: .image)
    }
    
    func testScheduleViewController() {
        let viewController = ScheduleViewController(currentSchedule: [.monday, .tuesday, .thursday, .saturday])
        assertSnapshot(of: viewController, as: .image)
    }
    
    func testStatisticsViewController() {
        let statsService = StatisticsService(
            trackerStore: TrackerStore.shared,
            trackerRecordStore: TrackerRecordStore.shared
        )
        let viewModel = StatisticsViewModel(statisticsService: statsService)
        let viewController = StatisticsViewController(viewModel: viewModel)
        assertSnapshot(of: viewController, as: .image)
    }
    
}

final class FilterViewModelDelegateFake: FiltersViewModelDelegate {
    func filtersViewModel(_ viewModel: HabitsTracker.FiltersViewModel, didSelectFilter filter: HabitsTracker.FilterOperation) {}
}

final class CategoriesViewModelDelegateFake: CategoriesViewModelDelegate {
    func categoriesViewModel(_ viewModel: HabitsTracker.CategoriesViewModel, didSelectCategory name: String) {}
}
