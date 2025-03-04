import SwiftUI
import Models

struct GraphNode: Identifiable {
    let id: UUID
    let note: Note
    var position: CGPoint
    var connections: [UUID]
}

struct GraphConnection: Identifiable {
    let id = UUID()
    let from: UUID
    let to: UUID
}

struct GraphNodeView: View {
    let node: GraphNode
    let isSelected: Bool
    let onNodeDragged: (CGPoint) -> Void
    let onNodeTapped: () -> Void
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color.blue : Color.gray)
                .frame(width: 30, height: 30)
                .position(node.position)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            onNodeDragged(value.location)
                        }
                )
                .onTapGesture(perform: onNodeTapped)
            
            if isSelected {
                Text(node.note.title)
                    .font(.caption)
                    .position(CGPoint(
                        x: node.position.x,
                        y: node.position.y - 20
                    ))
            }
        }
    }
}

struct GraphConnectionView: View {
    let fromPosition: CGPoint
    let toPosition: CGPoint
    
    var body: some View {
        Path { path in
            path.move(to: fromPosition)
            path.addLine(to: toPosition)
        }
        .stroke(Color.gray, lineWidth: 1)
    }
}

struct GraphView: View {
    @ObservedObject var store: ZettelkastenStore
    @State private var nodes: [GraphNode] = []
    @State private var connections: [GraphConnection] = []
    @State private var selectedNode: UUID?
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    
    func createGraph() {
        var newNodes: [GraphNode] = []
        var newConnections: [GraphConnection] = []
        
        // Erstelle Knoten
        for note in store.notes {
            let randomX = CGFloat.random(in: 50...350)
            let randomY = CGFloat.random(in: 50...350)
            let node = GraphNode(id: note.id,
                               note: note,
                               position: CGPoint(x: randomX, y: randomY),
                               connections: [])
            newNodes.append(node)
        }
        
        // Erstelle Verbindungen
        for node in newNodes {
            let links = node.note.links
            for link in links {
                if let targetNode = newNodes.first(where: { $0.note.noteId == link }) {
                    newConnections.append(GraphConnection(from: node.id, to: targetNode.id))
                }
            }
        }
        
        nodes = newNodes
        connections = newConnections
    }
    
    var graphContent: some View {
        ZStack {
            // Verbindungen
            ForEach(connections) { connection in
                if let fromNode = nodes.first(where: { $0.id == connection.from }),
                   let toNode = nodes.first(where: { $0.id == connection.to }) {
                    GraphConnectionView(fromPosition: fromNode.position,
                                     toPosition: toNode.position)
                }
            }
            
            // Knoten
            ForEach(nodes) { node in
                GraphNodeView(
                    node: node,
                    isSelected: selectedNode == node.id,
                    onNodeDragged: { newPosition in
                        if let index = nodes.firstIndex(where: { $0.id == node.id }) {
                            nodes[index].position = newPosition
                        }
                    },
                    onNodeTapped: {
                        selectedNode = node.id
                    }
                )
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            graphContent
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = value
                        }
                )
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            offset = CGSize(
                                width: offset.width + value.translation.width,
                                height: offset.height + value.translation.height
                            )
                        }
                )
        }
        .onAppear {
            createGraph()
        }
        .onChange(of: store.notes) { _, _ in
            createGraph()
        }
    }
}
