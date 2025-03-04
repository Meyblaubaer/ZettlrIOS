import SwiftUI
import Models

struct SearchView: View {
    @ObservedObject var store: ZettelkastenStore
    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var selectedTags: Set<String> = []
    @State private var showingTagFilter = false
    @State private var showingSimilarTerms = false
    @State private var similarTerms: [String] = []
    
    var body: some View {
        VStack {
            // Suchleiste
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Suchen...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: searchText) { _, newValue in
                        performSearch(query: newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
                
                Button(action: { showingTagFilter.toggle() }) {
                    Image(systemName: "tag")
                        .foregroundColor(selectedTags.isEmpty ? .gray : .blue)
                }
            }
            .padding()
            
            // Tag-Filter
            if showingTagFilter {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(TagManager.getAllTags(from: store.notes), id: \.tag) { tag, count in
                            TagButton(
                                tag: tag,
                                count: count,
                                isSelected: selectedTags.contains(tag)
                            ) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                                performSearch(query: searchText)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Ähnliche Begriffe
            if showingSimilarTerms && !similarTerms.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(similarTerms, id: \.self) { term in
                            Button(action: {
                                searchText = term
                                showingSimilarTerms = false
                            }) {
                                Text(term)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Suchergebnisse
            List(searchResults) { result in
                SearchResultRow(result: result)
            }
        }
    }
    
    private func performSearch(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        var filteredNotes = store.notes
        if !selectedTags.isEmpty {
            filteredNotes = filteredNotes.filter { note in
                !Set(note.tags).intersection(selectedTags).isEmpty
            }
        }
        
        searchResults = SearchManager.search(query: query, in: filteredNotes)
        
        // Ähnliche Begriffe finden
        if searchResults.isEmpty {
            similarTerms = SearchManager.findSimilarTerms(query, in: store.notes)
            showingSimilarTerms = !similarTerms.isEmpty
        } else {
            showingSimilarTerms = false
        }
    }
}

struct TagButton: View {
    let tag: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(tag)
                Text("(\(count))")
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(8)
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(result.note.title)
                .font(.headline)
            
            if !result.note.tags.isEmpty {
                HStack {
                    ForEach(result.note.tags, id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Zeige Matches im Content
            ForEach(result.matches.filter { $0.type == SearchResult.MatchType.content }, id: \.text) { match in
                Text(match.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
