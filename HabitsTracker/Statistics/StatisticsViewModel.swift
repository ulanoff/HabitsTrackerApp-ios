//
//  StatisticsViewModel.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 21.11.2023.
//

import Foundation

final class StatisticsViewModel {
    private let statisticsService: StatisticsService
    @Observable private(set) var statistics: Statistics
    @Observable private(set) var state: StatisticsState
    
    init(statisticsService: StatisticsService) {
        self.statisticsService = statisticsService
        let statistics = statisticsService.getStatitics()
        self.statistics = statistics
        state = statistics.isEmpty ? .empty : .standart
    }
    
    func updateStatistics() {
        statistics = statisticsService.getStatitics()
        state = statistics.isEmpty ? .empty : .standart
    }
}
