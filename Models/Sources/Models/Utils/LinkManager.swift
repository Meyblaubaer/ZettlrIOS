import Foundation

public class LinkManager {
    public static func extractLinks(from content: String) -> [String] {
        let pattern = "\\[\\[([^\\]]+)\\]\\]" // Sucht nach [[link]]
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex?.matches(in: content, range: range) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    public static func updateLinks(in notes: [Note], for updatedNote: Note) -> [Note] {
        var updatedNotes = notes
        
        // Entferne alte Backlinks
        updatedNotes = updatedNotes.map { note in
            var note = note
            note.backlinks = note.backlinks.filter { $0 != updatedNote.noteId }
            return note
        }
        
        // Füge neue Backlinks hinzu
        let linkedNoteIds = updatedNote.links
        updatedNotes = updatedNotes.map { note in
            var note = note
            if let noteId = note.noteId, linkedNoteIds.contains(noteId) {
                note.backlinks.append(updatedNote.noteId ?? "")
            }
            return note
        }
        
        return updatedNotes
    }
    
    public static func removeLinks(in notes: [Note], for deletedNote: Note) -> [Note] {
        var updatedNotes = notes
        
        // Entferne Backlinks
        if let noteId = deletedNote.noteId {
            updatedNotes = updatedNotes.map { note in
                var note = note
                note.backlinks = note.backlinks.filter { $0 != noteId }
                note.links = note.links.filter { $0 != noteId }
                return note
            }
        }
        
        return updatedNotes
    }
}
