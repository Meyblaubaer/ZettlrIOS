import Foundation
import Models
import Combine

class ContentViewModel: ObservableObject {
    @Published var editorViewModel: EditorViewModel
    private var store: ZettelkastenStore
    private var syncCoordinator: SyncCoordinator
    
    init(store: ZettelkastenStore, syncCoordinator: SyncCoordinator, editorViewModel: EditorViewModel) {
        self.store = store
        self.syncCoordinator = syncCoordinator
        self.editorViewModel = editorViewModel
    }
    
    @MainActor
    func createNewNote() async throws {
        let timestamp = Date()
        let formatter = ISO8601DateFormatter()
        
        let newNote = Note(
            id: UUID(),
            title: "New Note",
            content: "",
            tags: ["untagged"],
            metadata: [
                "created": formatter.string(from: timestamp),
                "version": "1.0"
            ],
            createdAt: timestamp,
            modifiedAt: timestamp
        )
        
        do {
            try await store.addNote(newNote)
            editorViewModel.selectedNote = newNote
            
            // Sync after successful note creation
            Task {
                try? await syncCoordinator.sync()
            }
        } catch {
            print("Failed to create new note: \(error)")
            throw error
        }
    }
}
