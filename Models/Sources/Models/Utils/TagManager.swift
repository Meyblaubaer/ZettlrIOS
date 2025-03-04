import Foundation

public class TagManager {
    public static func extractTags(from content: String) -> [String] {
        let pattern = "#([\\w-]+)" // Sucht nach #tag
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex?.matches(in: content, range: range) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    public static func updateTags(in note: Note) -> Note {
        var updatedNote = note
        let contentTags = extractTags(from: note.content)
        let titleTags = extractTags(from: note.title)
        updatedNote.tags = Array(Set(contentTags + titleTags))
        return updatedNote
    }
}
