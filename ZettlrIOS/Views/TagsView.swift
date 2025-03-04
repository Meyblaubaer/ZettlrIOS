import SwiftUI
import Models

struct TagsView: View {
    @ObservedObject var store: ZettelkastenStore
    @State private var selectedTag: String?
    @State private var showingRelatedTags = false
    
    var body: some View {
        List {
            Section(header: Text("Alle Tags")) {
                ForEach(TagManager.getAllTags(from: store.notes), id: \.tag) { tag, count in
                    HStack {
                        Text("#\(tag)")
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(count)")
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTag = tag
                        showingRelatedTags = true
                    }
                }
            }
            
            if let selectedTag = selectedTag, showingRelatedTags {
                Section(header: Text("Verwandte Tags zu #\(selectedTag)")) {
                    ForEach(TagManager.findRelatedTags(selectedTag, in: store.notes), id: \.tag) { tag, count in
                        HStack {
                            Text("#\(tag)")
                                .foregroundColor(.blue)
                            Spacer()
                            Text("\(count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("Notizen mit #\(selectedTag)")) {
                    ForEach(TagManager.findNotesByTag(selectedTag, in: store.notes)) { note in
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                            if !note.content.isEmpty {
                                Text(note.content.prefix(100))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
