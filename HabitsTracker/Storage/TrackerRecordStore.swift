//
//  TrackerRecordStore.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 06.11.2023.
//

import UIKit

enum TrackerRecordStoreError: Error {
    case convertingError
}

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()
    private let context = CoreDataManager.shared.context
    private let isMockDataMode: Bool
    private var firstFetch = true
    
    init() {
        guard let isMockDataMode = (UIApplication.shared.delegate as? AppDelegate)?.mockMode
        else {
            self.isMockDataMode = false
            assertionFailure("Failed to cast UIApplication Delegate to AppDelegate")
            return
        }
        self.isMockDataMode = isMockDataMode
    }
    
    func getAllRecords() throws -> [TrackerRecord] {
        if isMockDataMode && firstFetch {
            addMocks()
        }
        firstFetch = false
        let request = TrackerRecordCD.fetchRequest()
        guard let result = try? context.fetch(request) else {
            return []
        }
        
        return try result.map {
            try recordViewModel(from: $0)
        }
    }
    
    func getAllRecordsCD() -> [TrackerRecordCD] {
        let request = TrackerRecordCD.fetchRequest()
        if let result = try? context.fetch(request) {
            return result
        } else {
            return []
        }
    }
    
    func recordsFor(trackerID: UUID) -> Int {
        let allRecords = getAllRecordsCD()
        let trackerRecords = allRecords.filter {
            $0.trackerId == trackerID
        }
        return trackerRecords.count
    }
    
    func addMocks() {
        let mockRecords = MockService.shared.getMockRecords()
        for record in mockRecords {
            _ = createRecord(record)
        }
        saveContext()
    }
    
    func findRecord(_ record: TrackerRecord) -> TrackerRecordCD? {
        let request = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(
            format: "%K = %@ AND %K = %@",
            #keyPath(TrackerRecordCD.trackerId),
            record.trackerId as CVarArg,
            #keyPath(TrackerRecordCD.date),
            record.date as NSDate
        )
        let result = try? context.fetch(request)
        
        if let recordCD = result?.first {
            return recordCD
        } else {
            return nil
        }
    }
    
    func createRecord(_ record: TrackerRecord) -> TrackerRecordCD {
        let recordCD = TrackerRecordCD(context: context)
        recordCD.date = record.date
        recordCD.trackerId = record.trackerId
        
        saveContext()
        return recordCD
    }
    
    func deleteRecord(_ record: TrackerRecord) {
        if let recordCD = findRecord(record) {
            context.delete(recordCD)
        }
        saveContext()
    }
    
    func recordViewModel(from recordCD: TrackerRecordCD) throws -> TrackerRecord {
        guard
            let trackerId = recordCD.trackerId,
            let date = recordCD.date
        else {
            throw TrackerRecordStoreError.convertingError
        }
        
        return TrackerRecord(trackerId: trackerId, date: date)
    }
    
    func saveContext() {
        CoreDataManager.shared.saveContext()
    }
}
