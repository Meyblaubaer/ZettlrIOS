import Foundation

public struct SearchResult: Identifiable, Sendable {
    public let id: UUID
    
    public init(note: Note, matches: [Match], relevance: Double) {
        self.id = UUID()
        self.note = note
        self.matches = matches
        self.relevance = relevance
    }
    public let note: Note
    public let matches: [Match]
    public let relevance: Double
    
    public struct Match: Hashable, Sendable {
        public init(type: MatchType, text: String, range: Range<String.Index>, relevance: Double = 1.0) {
            self.type = type
            self.text = text
            self.range = range
            self.relevance = relevance
        }
        public let type: MatchType
        public let text: String
        public let range: Range<String.Index>
        public let relevance: Double
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(text)
            hasher.combine(type)
        }
    }
    
    public enum MatchType: String, Sendable {
        case title
        case content
        case tag
    }
}
