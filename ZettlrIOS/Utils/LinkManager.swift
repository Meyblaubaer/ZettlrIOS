import Foundation
import Models

class LinkManager {
    static func extractLinks(from content: String) -> [String] {
        let pattern = "\\[\\[([^\\]]+)\\]\\]" // Matches [[link]]
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex?.matches(in: content, range: range) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    static func updateBacklinks(notes: [Note], updatedNote: Note) -> [Note] {
        var updatedNotes = notes
        
        // Entferne alte Backlinks
        updatedNotes = updatedNotes.map { note in
            var note = note
            note.backlinks = note.backlinks.filter { $0 != updatedNote.noteId }
            return note
        }
        
        // Füge neue Backlinks hinzu
        let links = extractLinks(from: updatedNote.content)
        updatedNotes = updatedNotes.map { note in
            var note = note
            if let noteId = note.noteId, let updatedNoteId = updatedNote.noteId, links.contains(noteId) {
                note.backlinks.append(updatedNoteId)
            }
            return note
        }
        
        return updatedNotes
    }
    
    static func createWikiLink(to noteId: String) -> String {
        return "[[\(noteId)]]"
    }
    
    static func findRelatedNotes(note: Note, allNotes: [Note], maxResults: Int = 5) -> [Note] {
        // Gewichtung für verschiedene Beziehungsarten
        let directLinkWeight = 3.0
        let tagWeight = 2.0
        let titleWeight = 1.0
        
        var scores: [(note: Note, score: Double)] = []
        
        for otherNote in allNotes where otherNote.id != note.id {
            var score = 0.0
            
            // Direkte Links
            if note.links.contains(otherNote.noteId ?? "") {
                score += directLinkWeight
            }
            
            // Gemeinsame Tags
            let commonTags = Set(note.tags).intersection(Set(otherNote.tags))
            score += Double(commonTags.count) * tagWeight
            
            // Ähnlichkeit im Titel
            if note.title.lowercased().contains(otherNote.title.lowercased()) ||
               otherNote.title.lowercased().contains(note.title.lowercased()) {
                score += titleWeight
            }
            
            if score > 0 {
                scores.append((otherNote, score))
            }
        }
        
        // Sortiere nach Score und limitiere die Ergebnisse
        return scores.sorted { $0.score > $1.score }
            .prefix(maxResults)
            .map { $0.note }
    }
}
