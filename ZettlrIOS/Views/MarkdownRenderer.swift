import SwiftUI

struct MarkdownText: View {
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(parseMarkdown().enumerated()), id: \.offset) { _, element in
                element
            }
        }
    }
    
    private func parseMarkdown() -> [Text] {
        let lines = content.components(separatedBy: .newlines)
        var elements: [Text] = []
        
        for line in lines {
            if line.isEmpty {
                continue
            }
            
            // Headers
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let text = line.dropFirst(level + 1)
                elements.append(
                    Text(String(text))
                        .font(headerFont(for: level))
                        .bold()
                )
                continue
            }
            
            // Bold
            let boldPattern = "\\*\\*([^\\*]+)\\*\\*"
            var processedLine = line
            if let regex = try? NSRegularExpression(pattern: boldPattern) {
                let range = NSRange(processedLine.startIndex..., in: processedLine)
                processedLine = regex.stringByReplacingMatches(
                    in: processedLine,
                    range: range,
                    withTemplate: "$1"
                )
                
                elements.append(
                    Text(processedLine)
                        .bold()
                )
                continue
            }
            
            // Italic
            let italicPattern = "\\*([^\\*]+)\\*"
            if let regex = try? NSRegularExpression(pattern: italicPattern) {
                let range = NSRange(processedLine.startIndex..., in: processedLine)
                processedLine = regex.stringByReplacingMatches(
                    in: processedLine,
                    range: range,
                    withTemplate: "$1"
                )
                
                elements.append(
                    Text(processedLine)
                        .italic()
                )
                continue
            }
            
            // Links
            let linkPattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
            if let regex = try? NSRegularExpression(pattern: linkPattern) {
                let range = NSRange(processedLine.startIndex..., in: processedLine)
                let matches = regex.matches(in: processedLine, range: range)
                
                if let match = matches.first,
                   let textRange = Range(match.range(at: 1), in: processedLine),
                   let _ = Range(match.range(at: 2), in: processedLine) {
                    let text = String(processedLine[textRange])
                    elements.append(
                        Text(text)
                            .foregroundColor(.blue)
                            .underline()
                    )
                    continue
                }
            }
            
            // Plain text
            elements.append(Text(processedLine))
        }
        
        return elements
    }
    
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
}
