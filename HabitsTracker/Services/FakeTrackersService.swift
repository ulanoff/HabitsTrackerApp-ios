//
//  TrackersService.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 13.10.2023.
//

import Foundation

struct FakeUUIDs {
    static let uuid1 = UUID(uuidString: "e7b833a7-f1fd-4493-995b-215610d309ed")!
    static let uuid2 = UUID(uuidString: "5f4926ae-c977-4a22-8d45-486da677cc91")!
    static let uuid3 = UUID(uuidString: "08b2c611-ffcc-4be8-94d1-241bd642ee95")!
    static let uuid4 = UUID(uuidString: "3076d8bf-da13-4b91-a0a0-ba197cfc53e3")!
    static let uuid5 = UUID(uuidString: "fdb9aaac-2800-4858-91b9-e660965fb4a8")!
}

final class FakeTrackersService {
    static func getTrackers() -> [TrackerCategory] {
        [
            TrackerCategory(
                name: "Домашний уют",
                trackers: [
                    Tracker(
                        id: FakeUUIDs.uuid1,
                        name: "Поливать растения",
                        color: .ypSelection5,
                        emoji: "❤️",
                        schedule: [.sunday, .monday]
                    ),
                ]
            ),
            TrackerCategory(
                name: "Саморазвитие",
                trackers: [
                    Tracker(
                        id: FakeUUIDs.uuid5,
                        name: "Воркаут",
                        color: .ypSelection14,
                        emoji: "💪🏼",
                        schedule: [.tuesday, .saturday, .sunday]
                    ),
                ]
            ),
            TrackerCategory(
                name: "Радостные мелочи",
                trackers: [
                    Tracker(
                        id: FakeUUIDs.uuid2,
                        name: "Кошка заслонила камеру на созвоне",
                        color: .ypSelection2,
                        emoji: "😻",
                        schedule: [.tuesday, .wednesday]
                    ),
                    Tracker(
                        id: FakeUUIDs.uuid3,
                        name: "Бабушка прислала открытку в вотсапе",
                        color: .ypSelection1,
                        emoji: "🌺",
                        schedule: [.sunday, .friday, .saturday]
                    ),
                    Tracker(
                        id: FakeUUIDs.uuid4,
                        name: "Свидания в апреле",
                        color: .ypSelection14,
                        emoji: "❤️",
                        schedule: [.tuesday, .sunday]
                    ),
                ]
            ),
        ]
    }
    
    static func getTrackerRecords() -> [TrackerRecord] {
        let todayDate = Date()
        let yesterday = todayDate.yesterday
        return [
            TrackerRecord(trackerId: FakeUUIDs.uuid1, date: todayDate),
            TrackerRecord(trackerId: FakeUUIDs.uuid2, date: todayDate),
            TrackerRecord(trackerId: FakeUUIDs.uuid3, date: yesterday),
            TrackerRecord(trackerId: FakeUUIDs.uuid4, date: yesterday)
        ]
    }
}
