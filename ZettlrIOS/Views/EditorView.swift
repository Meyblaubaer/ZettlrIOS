import SwiftUI
import Down
import Models

class EditorViewModel: ObservableObject {
    @Published var selectedNote: Note?
    private let store: ZettelkastenStore
    let syncCoordinator: SyncCoordinator
    var titleUpdateTask: Task<Void, Never>?
    var contentUpdateTask: Task<Void, Never>?
    
    init(store: ZettelkastenStore, syncCoordinator: SyncCoordinator) {
        self.store = store
        self.syncCoordinator = syncCoordinator
    }
    
    @MainActor
    func updateNoteContent(_ newContent: String) async throws {
        guard var note = selectedNote else { return }
        note.content = newContent
        note.modifiedAt = Date()
        
        try await store.updateNote(note)
        selectedNote = note
        try await syncCoordinator.sync()
    }
    
    @MainActor
    func updateNoteTitle(_ newTitle: String) async throws {
        guard var note = selectedNote else { return }
        note.title = newTitle
        note.modifiedAt = Date()
        
        try await store.updateNote(note)
        selectedNote = note
        try await syncCoordinator.sync()
    }
    
    @MainActor
    func deleteNote() async throws {
        guard let note = selectedNote else { return }
        
        try await store.deleteNote(note)
        selectedNote = nil
        try await syncCoordinator.sync()
    }
}

import SwiftUI

struct EditorView: View {
    @ObservedObject var viewModel: EditorViewModel
    @State private var isPreviewActive = false
    
    private func headerFont(for level: Int) -> Font {
        switch level {
        case 1: return .largeTitle
        case 2: return .title
        case 3: return .title2
        case 4: return .title3
        case 5: return .headline
        default: return .body
        }
    }
    @State private var showMetadata = false
    @State private var noteContent: String = ""
    @State private var noteTitle: String = ""
    @State private var editorMode: EditorMode = .markdown
    
    enum EditorMode {
        case markdown
        case preview
        case raw
    }
    
    var body: some View {
        if let note = viewModel.selectedNote {
            Group {
                if isPreviewActive {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(noteTitle)
                                .font(.title)
                                .padding(.bottom, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                let lines = noteContent.components(separatedBy: .newlines)
                                ForEach(lines.indices, id: \.self) { index in
                                    let line = lines[index]
                                    if !line.isEmpty {
                                        if line.hasPrefix("#") {
                                            let level = line.prefix(while: { $0 == "#" }).count
                                            let text = line.dropFirst(level + 1)
                                            Text(String(text))
                                                .font(headerFont(for: level))
                                                .bold()
                                        } else if line.contains("**") {
                                            Text(line.replacingOccurrences(of: "**", with: ""))
                                                .bold()
                                        } else if line.contains("*") {
                                            Text(line.replacingOccurrences(of: "*", with: ""))
                                                .italic()
                                        } else {
                                            Text(line)
                                        }
                                    }
                                }
                            }
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                } else {
                    VStack(spacing: 0) {
                        TextField("Title", text: $noteTitle)
                            .font(.title)
                            .textFieldStyle(PlainTextFieldStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .onChange(of: noteTitle) { oldTitle, newTitle in
                                if oldTitle != newTitle {
                                    let task = Task {
                                        do {
                                            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden Debounce
                                            try await viewModel.updateNoteTitle(newTitle)
                                        } catch {
                                            if !(error is CancellationError) {
                                                print("Error updating title: \(error)")
                                            }
                                        }
                                    }
                                    
                                    // Breche vorherige Tasks ab
                                    Task { @MainActor in
                                        if let existingTask = viewModel.titleUpdateTask {
                                            existingTask.cancel()
                                        }
                                        viewModel.titleUpdateTask = task
                                    }
                                }
                            }
                        Divider()
                        
                        TextEditor(text: $noteContent)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .background(Color(.systemBackground))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .onChange(of: noteContent) { oldContent, newContent in
                                if oldContent != newContent {
                                    let task = Task {
                                        do {
                                            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden Debounce
                                            if noteContent == newContent { // Prüfen ob sich der Content nicht wieder geändert hat
                                                try await viewModel.updateNoteContent(newContent)
                                            }
                                        } catch {
                                            if !(error is CancellationError) {
                                                print("Error updating content: \(error)")
                                            }
                                        }
                                    }
                                    
                                    // Breche vorherige Tasks ab
                                    Task { @MainActor in
                                        if let existingTask = viewModel.contentUpdateTask {
                                            existingTask.cancel()
                                        }
                                        viewModel.contentUpdateTask = task
                                    }
                                }
                            }
                    }
                }
            }
            .padding()
            .navigationTitle("Note")
            .navigationBarItems(trailing:
                HStack(spacing: 16) {
                    Button(action: { isPreviewActive.toggle() }) {
                        Label(isPreviewActive ? "Edit" : "Preview", systemImage: isPreviewActive ? "pencil" : "eye")
                    }
                    
                    Button(action: { showMetadata.toggle() }) {
                        Label("Info", systemImage: "info.circle")
                    }
                }
            )
            .sheet(isPresented: $showMetadata) {
                MetadataView(note: note)
            }
            .onAppear {
                noteContent = note.content
                noteTitle = note.title
            }
            .onChange(of: note) { _, newNote in
                noteContent = newNote.content
                noteTitle = newNote.title
            }
        } else {
            Text("Select a note")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}

struct MetadataView: View {
    let note: Note
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tags")) {
                    ForEach(note.tags, id: \.self) { tag in
                        Text(tag)
                    }
                }
                
                Section(header: Text("Metadata")) {
                    ForEach(Array(note.metadata.keys.sorted()), id: \.self) { key in
                        if let value = note.metadata[key] {
                            HStack {
                                Text(key)
                                Spacer()
                                Text(value)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Section(header: Text("Details")) {
                    HStack {
                        Text("Created")
                        Spacer()
                        Text(note.createdAt, style: .date)
                    }
                    HStack {
                        Text("Modified")
                        Spacer()
                        Text(note.modifiedAt, style: .date)
                    }
                }
            }
            .navigationTitle("Note Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
