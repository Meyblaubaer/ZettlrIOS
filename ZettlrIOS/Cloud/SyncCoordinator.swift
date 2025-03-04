import Foundation
import CloudKit
import Combine

@MainActor
class SyncCoordinator: ObservableObject {
    @Published private(set) var isSyncing = false
    @Published private(set) var lastSyncError: Error?
    
    private let container: CKContainer
    private let database: CKDatabase
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        container = CKContainer.default()
        database = container.privateCloudDatabase
        setupSubscription()
    }
    
    private func setupSubscription() {
        let subscriptionID = "note-changes-subscription"
        let subscription = CKQuerySubscription(
            recordType: "Note",
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        Task {
            do {
                try await database.save(subscription)
            } catch {
                print("Error setting up subscription: \(error)")
            }
        }
    }
    
    @MainActor
    func sync() async throws {
        guard !isSyncing else { return }
        
        isSyncing = true
        lastSyncError = nil
        
        do {
            let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
            _ = try await database.records(matching: query)
            isSyncing = false
        } catch {
            lastSyncError = error
            isSyncing = false
            throw error
        }
    }
}
