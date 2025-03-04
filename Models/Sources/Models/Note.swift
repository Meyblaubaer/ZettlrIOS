import Foundation
import CloudKit

public struct Note: Identifiable, Codable, Sendable, Equatable, Hashable {
    public static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }
    public let id: UUID
    public var title: String
    public var content: String
    public var tags: [String]
    public var metadata: [String: String]
    public var createdAt: Date
    public var modifiedAt: Date
    
    // Zettelkasten-spezifische Felder
    public var noteId: String? // Eindeutige ID im Zettelkasten-Format (z.B. 202503041712)
    public var links: [String] // IDs der verlinkten Notizen
    public var backlinks: [String] // IDs der Notizen, die auf diese Notiz verweisen
    public var references: [String] // Zitate und Referenzen
    public var type: NoteType // Art der Notiz (Literatur, Permanent, Flüchtig)
    
    public enum NoteType: String, Codable, Sendable {
        case literature // Literaturnotiz
        case permanent // Permanente Notiz
        case fleeting  // Flüchtige Notiz
    }
    
    public init(id: UUID = UUID(), 
         title: String = "", 
         content: String = "", 
         tags: [String] = [], 
         metadata: [String: String] = [:], 
         createdAt: Date = Date(),
         modifiedAt: Date = Date(),
         noteId: String? = nil,
         links: [String] = [],
         backlinks: [String] = [],
         references: [String] = [],
         type: NoteType = .fleeting) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.metadata = metadata
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.noteId = noteId
        self.links = links
        self.backlinks = backlinks
        self.references = references
        self.type = type
    }
    
    // Generiere eine neue Zettelkasten-ID im Format YYYYMMDDHHMM
    public static func generateNoteId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        return formatter.string(from: Date())
    }
    
    // Extrahiere Links aus dem Content
    public func extractLinks() -> [String] {
        let pattern = "\\[\\[([^\\]]+)\\]\\]" // Sucht nach [[link]]
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex?.matches(in: content, range: range) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    // Erstelle eine neue verlinkte Notiz
    public func createLinkedNote(title: String, content: String, type: NoteType) -> Note {
        var newNote = Note(title: title,
                         content: content,
                         noteId: Note.generateNoteId(),
                         type: type)
        newNote.links = [self.noteId].compactMap { $0 }
        return newNote
    }
}
