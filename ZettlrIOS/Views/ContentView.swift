import SwiftUI
import Models

// MARK: - Tag View
struct TagView: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(12)
    }
}

// MARK: - Note List Item
struct NoteListItem: View {
    let note: Note
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .imageScale(.medium)
                }
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
                .buttonStyle(.borderless)
            }
            
            if !note.content.isEmpty {
                Text(note.content.prefix(50))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 8) {
                        ForEach(note.tags, id: \.self) { tag in
                            TagView(tag: tag)
                        }
                    }
                    .padding(.horizontal, 1)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}
    


struct NoteListView: View {
    @ObservedObject var store: ZettelkastenStore
    @ObservedObject var viewModel: ContentViewModel
    @State private var noteToDelete: Note?
    @State private var showDeleteAlert = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(store.notes) { note in
                    NavigationLink(value: note) {
                        NoteListItem(note: note) {
                            noteToDelete = note
                            showDeleteAlert = true
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 1)
        }
        .navigationTitle("Notes")
        .navigationDestination(for: Note.self) { note in
            EditorView(viewModel: viewModel.editorViewModel)
                .onAppear {
                    viewModel.editorViewModel.selectedNote = note
                }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        do {
                            try await viewModel.createNewNote()
                        } catch {
                            print("Error creating new note: \(error)")
                        }
                    }
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let note = noteToDelete {
                    Task {
                        try? await store.deleteNote(note)
                        noteToDelete = nil
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            if let note = noteToDelete {
                Text("Delete note " + note.title + "?")
            }
        }
    }
}

struct NoteDetailView: View {
    let viewModel: EditorViewModel
    
    var body: some View {
        if viewModel.selectedNote != nil {
            EditorView(viewModel: viewModel)
        } else {
            Text("Select a note or create a new one")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}

struct TabContentView: View {
    @ObservedObject var store: ZettelkastenStore
    let index: Int
    
    var body: some View {
        switch index {
        case 1:
            NavigationView {
                SearchView(store: store)
            }
        case 2:
            NavigationView {
                GraphView(store: store)
            }
        case 3:
            NavigationView {
                TagsView(store: store)
            }
        default:
            EmptyView()
        }
    }
}

struct ContentView: View {
    @ObservedObject var store: ZettelkastenStore
    @ObservedObject var syncCoordinator: SyncCoordinator
    @StateObject private var viewModel: ContentViewModel
    @State private var selectedTab: Int = 0
    @State private var isShowingNewTagSheet = false
    
    init(store: ZettelkastenStore, syncCoordinator: SyncCoordinator) {
        self.store = store
        self.syncCoordinator = syncCoordinator
        let editorViewModel = EditorViewModel(store: store, syncCoordinator: syncCoordinator)
        _viewModel = StateObject(wrappedValue: ContentViewModel(store: store, syncCoordinator: syncCoordinator, editorViewModel: editorViewModel))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Notizen-Tab
            NavigationSplitView {
                NoteListView(store: store, viewModel: viewModel)
            } detail: {
                NoteDetailView(viewModel: viewModel.editorViewModel)
            }
            .tabItem {
                Label("Notes", systemImage: "doc.text")
            }
            .tag(0)
            
            // Andere Tabs
            ForEach(1...3, id: \.self) { index in
                TabContentView(store: store, index: index)
                    .tabItem {
                        switch index {
                        case 1:
                            Label("Search", systemImage: "magnifyingglass")
                        case 2:
                            Label("Graph", systemImage: "circle.grid.cross")
                        case 3:
                            Label("Tags", systemImage: "tag")
                        default:
                            EmptyView()
                        }
                    }
                    .tag(index)
            }
        }
        .sheet(isPresented: $isShowingNewTagSheet) {
            NavigationView {
                VStack {
                    TextField("Tag Name", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Add Tag") {
                        // TODO: Add tag logic
                        isShowingNewTagSheet = false
                    }
                    .padding()
                }
                .navigationTitle("New Tag")
                .navigationBarItems(trailing: Button("Cancel") {
                    isShowingNewTagSheet = false
                })
            }
        }
        .task {
            try? await store.loadNotes()
        }
    }
}
