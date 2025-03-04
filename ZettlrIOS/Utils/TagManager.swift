import Foundation
import Models

class TagManager {
    static func extractTags(from content: String) -> [String] {
        let pattern = "#([\\w-]+)" // Matches #tag
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(content.startIndex..., in: content)
        let matches = regex?.matches(in: content, range: range) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: content) else { return nil }
            return String(content[range])
        }
    }
    
    static func getAllTags(from notes: [Note]) -> [(tag: String, count: Int)] {
        var tagCounts: [String: Int] = [:]
        
        for note in notes {
            for tag in note.tags {
                tagCounts[tag, default: 0] += 1
            }
        }
        
        return tagCounts.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    static func findNotesByTag(_ tag: String, in notes: [Note]) -> [Note] {
        return notes.filter { $0.tags.contains(tag) }
    }
    
    static func findRelatedTags(_ tag: String, in notes: [Note]) -> [(tag: String, count: Int)] {
        let notesWithTag = findNotesByTag(tag, in: notes)
        var relatedTags: [String: Int] = [:]
        
        for note in notesWithTag {
            for noteTag in note.tags where noteTag != tag {
                relatedTags[noteTag, default: 0] += 1
            }
        }
        
        return relatedTags.map { ($0.key, $0.value) }
            .sorted { $0.1 > $1.1 }
    }
    
    static func suggestTags(for content: String, from existingTags: [String]) -> [String] {
        let words = content.lowercased().split(separator: " ")
        return existingTags.filter { tag in
            words.contains { $0.contains(tag.lowercased()) }
        }
    }
}
