import Foundation
import Models

// Using SearchResult from Models

fileprivate struct Match {
    let text: String
    let type: SearchResult.MatchType
    let relevance: Double
}

class SearchManager {
    static func search(query: String, in notes: [Note]) -> [SearchResult] {
        let searchTerms = query.lowercased().split(separator: " ")
        var results: [SearchResult] = []
        
        for note in notes {
            var matches: [Match] = []
            var totalRelevance: Double = 0
            
            // Titel durchsuchen
            if searchTerms.contains(where: { note.title.lowercased().contains($0) }) {
                matches.append(Match(text: note.title, type: SearchResult.MatchType.title, relevance: 1.0))
                totalRelevance += 1.0
            }
            
            // Content durchsuchen
            for term in searchTerms {
                if let range = note.content.lowercased().range(of: term) {
                    let start = note.content.index(range.lowerBound, offsetBy: -20, limitedBy: note.content.startIndex) ?? note.content.startIndex
                    let end = note.content.index(range.upperBound, offsetBy: 20, limitedBy: note.content.endIndex) ?? note.content.endIndex
                    let context = String(note.content[start..<end])
                    matches.append(Match(text: context, type: SearchResult.MatchType.content, relevance: 0.5))
                    totalRelevance += 0.5
                }
            }
            
            // Tags durchsuchen
            for tag in note.tags {
                if searchTerms.contains(where: { tag.lowercased().contains($0) }) {
                    matches.append(Match(text: tag, type: SearchResult.MatchType.tag, relevance: 0.8))
                    totalRelevance += 0.8
                }
            }
            
            if !matches.isEmpty {
                results.append(SearchResult(note: note, matches: matches.map { match in
                    SearchResult.Match(type: match.type, text: match.text, range: match.text.startIndex..<match.text.endIndex, relevance: match.relevance)
                }, relevance: totalRelevance))
            }
        }
        
        // Sortiere nach Relevanz
        return results.sorted { result1, result2 in
            let relevance1 = result1.matches.reduce(0.0) { $0 + $1.relevance }
            let relevance2 = result2.matches.reduce(0.0) { $0 + $1.relevance }
            return relevance1 > relevance2
        }
    }
    
    static func findSimilarTerms(_ query: String, in notes: [Note]) -> [String] {
        var terms = Set<String>()
        let queryWords = query.lowercased().split(separator: " ")
        
        for note in notes {
            // Füge ähnliche Wörter aus Titel hinzu
            let titleWords = note.title.lowercased().split(separator: " ")
            for queryWord in queryWords {
                terms.formUnion(titleWords.filter { word in
                    let distance = levenshteinDistance(String(queryWord), word.description)
                    return distance <= 2 && distance > 0
                }.map { String($0) })
            }
            
            // Füge ähnliche Tags hinzu
            for tag in note.tags {
                for queryWord in queryWords {
                    let distance = levenshteinDistance(String(queryWord), tag.lowercased())
                    if distance <= 2 && distance > 0 {
                        terms.insert(tag)
                    }
                }
            }
        }
        
        return Array(terms)
    }
    
    private static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        var matrix = Array(repeating: Array(repeating: 0, count: s2.count + 1), count: s1.count + 1)
        
        for i in 0...s1.count {
            matrix[i][0] = i
        }
        
        for j in 0...s2.count {
            matrix[0][j] = j
        }
        
        for i in 1...s1.count {
            for j in 1...s2.count {
                let cost = s1[i-1] == s2[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,
                    matrix[i][j-1] + 1,
                    matrix[i-1][j-1] + cost
                )
            }
        }
        
        return matrix[s1.count][s2.count]
    }
}
