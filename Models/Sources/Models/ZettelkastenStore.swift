import Foundation
import Combine

@MainActor
public class ZettelkastenStore: ObservableObject {
    @Published public var notes: [Note] = []
    private let storage: StorageManager
    private var updateTasks: [UUID: Task<Void, Error>] = [:]
    
    public init(storage: StorageManager = StorageManager()) {
        self.storage = storage
        loadNotesTask()
    }
    
    private func loadNotesTask() {
        Task { @MainActor in
            do {
                try await loadNotes()
            } catch {
                print("Error loading notes: \(error)")
            }
        }
    }
    
    public func loadNotes() async throws {
        let loadedNotes = try await storage.loadNotes()
        self.notes = loadedNotes
    }
    

    
    public func addNote(_ note: Note) async throws {
        var newNote = note
        
        // Links aus dem Content extrahieren
        newNote.links = LinkManager.extractLinks(from: newNote.content)
        
        // Tags aktualisieren
        newNote = TagManager.updateTags(in: newNote)
        
        // Notiz speichern
        let storage = self.storage
        try await storage.saveNote(newNote)
        
        // Links aktualisieren
        let currentNotes = self.notes
        let updatedNotes = LinkManager.updateLinks(in: currentNotes, for: newNote)
        
        // Alle aktualisierten Notizen speichern
        for noteToUpdate in updatedNotes where noteToUpdate.id != newNote.id {
            try await storage.saveNote(noteToUpdate)
        }
        
        self.notes = updatedNotes
    }
    
    public func updateNote(_ note: Note) async throws {
        var updatedNote = note
        
        // Links aus dem Content extrahieren
        updatedNote.links = LinkManager.extractLinks(from: updatedNote.content)
        
        // Tags aktualisieren
        updatedNote = TagManager.updateTags(in: updatedNote)
        
        // Sofort die lokale Liste aktualisieren
        var currentNotes = self.notes
        if let index = currentNotes.firstIndex(where: { $0.id == note.id }) {
            currentNotes[index] = updatedNote
            self.notes = currentNotes
        }
        
        // Abbrechen des vorherigen Update-Tasks für diese Notiz
        updateTasks[note.id]?.cancel()
        
        // Neuen Update-Task erstellen
        let storage = self.storage
        let task = Task { @MainActor in
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden warten
            if !Task.isCancelled {
                // Links aktualisieren
                let currentNotes = self.notes
                let updatedNotes = LinkManager.updateLinks(in: currentNotes, for: updatedNote)
                
                // Alle Notizen speichern
                try await storage.saveNote(updatedNote)
                for noteToUpdate in updatedNotes where noteToUpdate.id != updatedNote.id {
                    try await storage.saveNote(noteToUpdate)
                }
                
                self.notes = updatedNotes
            }
        }
        
        updateTasks[note.id] = task
        try await task.value
        updateTasks[note.id] = nil
    }
    
    public func deleteNote(_ note: Note) async throws {
        // Links aktualisieren
        let currentNotes = self.notes
        let updatedNotes = LinkManager.removeLinks(in: currentNotes, for: note)
        
        // Speichere die Änderungen
        let storage = self.storage
        try await storage.deleteNote(note)
        
        for noteToUpdate in updatedNotes {
            try await storage.saveNote(noteToUpdate)
        }
        
        // Entferne die Notiz aus der lokalen Liste
        self.notes = updatedNotes.filter { $0.id != note.id }
    }
}
