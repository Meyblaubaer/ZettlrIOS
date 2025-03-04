import SwiftUI

struct SyncStatusView: View {
    @ObservedObject var syncCoordinator: SyncCoordinator
    
    var body: some View {
        HStack {
            if syncCoordinator.isSyncing {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)
                Text("Syncing...")
                    .font(.caption)
            } else if let error = syncCoordinator.lastSyncError {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
            } else {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
                Text("Synced")
                    .font(.caption)
            }
        }
        .padding(.horizontal)
    }
}
