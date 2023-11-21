//
//  TrackerRecordStore.swift
//  HabitsTracker
//
//  Created by Andrey Ulanov on 06.11.2023.
//

import Foundation

enum TrackerRecordStoreError: Error {
    case convertingError
}

final class TrackerRecordStore {
    private let context = CoreDataManager.shared.context
    
    func allRecords() throws -> [TrackerRecord] {
        let request = TrackerRecordCD.fetchRequest()
        guard let result = try? context.fetch(request) else {
            return []
        }
        
        return try result.map {
            try recordViewModel(from: $0)
        }
    }
    
    func allRecordsCD() -> [TrackerRecordCD] {
        let request = TrackerRecordCD.fetchRequest()
        if let result = try? context.fetch(request) {
            return result
        } else {
            return []
        }
    }
    
    func recordsFor(trackerID: UUID) -> Int {
        let allRecords = allRecordsCD()
        let trackerRecords = allRecords.filter {
            $0.trackerId == trackerID
        }
        return trackerRecords.count
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
