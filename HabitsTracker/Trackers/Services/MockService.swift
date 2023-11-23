//
//  MockService.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 22.11.2023.
//

import Foundation

fileprivate struct MockUUIDs {
    static let uuid1 = UUID(uuidString: "5b66ae0c-7f8a-4aca-b843-a8c66b1ddda0")!
    static let uuid2 = UUID(uuidString: "829fcc4b-b209-441b-9350-86b20eca6c1d")!
    static let uuid3 = UUID(uuidString: "e58d86e9-4080-4733-ab9a-c6f74c17ecb6")!
    static let uuid4 = UUID(uuidString: "0b91cea8-f181-4400-8ba8-f4842954aaf8")!
}

final class MockService {
    static let shared = MockService()
    
    func getMockCategories() -> [TrackerCategory] {
        [
            TrackerCategory(name: "Habits", trackers: [
                Tracker(
                    id: MockUUIDs.uuid1,
                    isPinned: false,
                    name: "Habit 1",
                    color: .ypSelection1,
                    emoji: TrackerConstants.trackerEmojis[0],
                    schedule: WeekDay.allCases,
                    type: .habit
                ),
                Tracker(
                    id: MockUUIDs.uuid2,
                    isPinned: false,
                    name: "Habit 2",
                    color: .ypSelection2,
                    emoji: TrackerConstants.trackerEmojis[1],
                    schedule: WeekDay.allCases,
                    type: .habit
                ),
                Tracker(
                    id: MockUUIDs.uuid3,
                    isPinned: false,
                    name: "Habit 3",
                    color: .ypSelection4,
                    emoji: TrackerConstants.trackerEmojis[2],
                    schedule: WeekDay.allCases,
                    type: .habit
                ),
            ]),
            TrackerCategory(name: "Events", trackers: [
                Tracker(
                    id: MockUUIDs.uuid4,
                    isPinned: false,
                    name: "Event",
                    color: .ypSelection5,
                    emoji: TrackerConstants.trackerEmojis[3],
                    schedule: WeekDay.allCases,
                    type: .irregularEvent
                ),
            ])
        ]
    }
    
    func getMockRecords() -> [TrackerRecord] {
        [
            TrackerRecord(trackerId: MockUUIDs.uuid1, date: Date().onlyDate),
            TrackerRecord(trackerId: MockUUIDs.uuid1, date: Date().yesterday.onlyDate),
            TrackerRecord(trackerId: MockUUIDs.uuid2, date: Date().yesterday.onlyDate),
            TrackerRecord(trackerId: MockUUIDs.uuid3, date: Date().yesterday.yesterday.onlyDate),
            TrackerRecord(trackerId: MockUUIDs.uuid4, date: Date().onlyDate),
        ]
    }
    
    func getMockTracker() -> Tracker {
        Tracker(
            id: MockUUIDs.uuid1,
            isPinned: false,
            name: "Habit 1",
            color: .ypSelection1,
            emoji: TrackerConstants.trackerEmojis[0],
            schedule: WeekDay.allCases,
            type: .habit
        )
    }
}
