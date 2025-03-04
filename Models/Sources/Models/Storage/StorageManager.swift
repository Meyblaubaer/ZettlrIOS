import Foundation
import CloudKit

@available(macOS 12.0, *)
public final class StorageManager: @unchecked Sendable {
    private let container: CKContainer
    private let database: CKDatabase
    
    public init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
    }
    
    public nonisolated func loadNotes() async throws -> [Note] {
        let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
        let records = try await database.records(matching: query)
        return try records.matchResults.compactMap { try $0.1.get() }.compactMap(decodeNote)
    }
    
    private func retryOperation<T>(_ operation: @escaping () async throws -> T, maxRetries: Int = 3) async throws -> T {
        var lastError: Error?
        
        for attempt in 0..<maxRetries {
            do {
                if attempt > 0 {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
                }
                return try await operation()
            } catch let error as CKError {
                lastError = error
                
                switch error.code {
                case .serverRecordChanged, .networkFailure, .networkUnavailable, .serviceUnavailable:
                    continue
                default:
                    throw error
                }
            } catch {
                throw error
            }
        }
        
        if let error = lastError {
            throw error
        } else {
            throw CKError(.internalError)
        }
    }
    
    private func saveRecord(_ note: Note) async throws {
        let recordID = CKRecord.ID(recordName: note.id.uuidString)
        let record: CKRecord
        
        do {
            record = try await database.record(for: recordID)
        } catch {
            if (error as? CKError)?.code == .unknownItem {
                record = CKRecord(recordType: "Note", recordID: recordID)
            } else {
                throw error
            }
        }
        
        record["title"] = note.title as CKRecordValue
        record["content"] = note.content as CKRecordValue
        record["tags"] = (note.tags.isEmpty ? ["untagged"] : note.tags) as CKRecordValue
        let defaultMetadata = ["created": ISO8601DateFormatter().string(from: note.createdAt)]
        let metadata = (note.metadata.isEmpty ? defaultMetadata : note.metadata) as [String: String]
        record["metadata"] = try JSONEncoder().encode(metadata) as CKRecordValue
        record["createdAt"] = note.createdAt as CKRecordValue
        record["modifiedAt"] = note.modifiedAt as CKRecordValue
        
        let configuration = CKOperation.Configuration()
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.configuration = configuration
        modifyOperation.savePolicy = .changedKeys
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            modifyOperation.modifyRecordsResultBlock = { result in
                switch result {
                case .success(_):
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            database.add(modifyOperation)
        }
    }
    
    public nonisolated func saveNote(_ note: Note) async throws {
        try await retryOperation({ () async throws -> Void in
            try await self.saveRecord(note)
        }, maxRetries: 3)
    }
    
    public nonisolated func deleteNote(_ note: Note) async throws {
        let recordID = CKRecord.ID(recordName: note.id.uuidString)
        try await database.deleteRecord(withID: recordID)
    }
    
    private func encodeNote(_ note: Note) throws -> CKRecord {
        let recordID = CKRecord.ID(recordName: note.id.uuidString)
        let record = CKRecord(recordType: "Note", recordID: recordID)
        let encoder = JSONEncoder()
        record["title"] = note.title
        record["content"] = note.content
        record["tags"] = note.tags.isEmpty ? ["untagged"] : note.tags
        let metadata = note.metadata.isEmpty ? ["created": ISO8601DateFormatter().string(from: Date())] : note.metadata
        record["metadata"] = try encoder.encode(metadata)
        record["createdAt"] = Date()
        record["modifiedAt"] = Date()
        return record
    }
    
    private func decodeNote(from record: CKRecord) -> Note? {
        guard let title = record["title"] as? String,
              let content = record["content"] as? String,
              let tags = record["tags"] as? [String],
              let metadataData = record["metadata"] as? Data,
              let createdAt = record["createdAt"] as? Date,
              let modifiedAt = record["modifiedAt"] as? Date,
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let metadata = try? decoder.decode([String: String].self, from: metadataData) else {
            return nil
        }
        
        var note = Note(id: id, title: title, content: content, tags: tags, metadata: metadata)
        note.createdAt = createdAt
        note.modifiedAt = modifiedAt
        return note
    }
}
