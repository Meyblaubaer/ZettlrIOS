import SwiftUI
import Models

struct ZettlrIOSApp: App {
    @StateObject private var store = ZettelkastenStore()
    @StateObject private var syncCoordinator = SyncCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store, syncCoordinator: syncCoordinator)
        }
    }
}
