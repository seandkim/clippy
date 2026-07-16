import Foundation

/// A single captured clipboard payload. `Equatable` so the store can dedup by content.
public enum ClipContent: Equatable {
    case text(String)
    case image(data: Data, width: Int, height: Int)
    case concealed(text: String)

    /// Single-line, human-readable label for the menu. Never exposes concealed plaintext.
    public var previewText: String {
        switch self {
        case .text(let s):
            return Self.singleLine(s, max: 50)
        case .image(_, let w, let h):
            return "Image \(w)×\(h)"
        case .concealed:
            return "🔒 ••••••••"
        }
    }

    private static func singleLine(_ s: String, max: Int) -> String {
        let collapsed = s.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
            .joined(separator: " ")
        if collapsed.count <= max { return collapsed }
        return String(collapsed.prefix(max - 1)) + "…"
    }
}
