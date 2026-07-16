import Foundation

/// One item in the history: content plus when it was (re)captured.
public struct Entry: Equatable, Identifiable {
    public let id: UUID
    public var timestamp: Date
    public let content: ClipContent

    public init(id: UUID = UUID(), timestamp: Date, content: ClipContent) {
        self.id = id
        self.timestamp = timestamp
        self.content = content
    }
}

/// In-memory, newest-first clipboard history. Enforces a count cap and an age cap,
/// dedups by content, and never persists anything.
public final class HistoryStore {
    public private(set) var entries: [Entry] = []

    private let maxEntries: Int
    private let maxAge: TimeInterval
    private let now: () -> Date

    public init(maxEntries: Int = 10,
                maxAge: TimeInterval = 3600,
                now: @escaping () -> Date = Date.init) {
        self.maxEntries = maxEntries
        self.maxAge = maxAge
        self.now = now
    }

    /// Insert new content at the top. If identical content already exists it is moved
    /// to the top with a refreshed timestamp (dedup). Applies expiry and count caps.
    public func insert(_ content: ClipContent) {
        prune()
        entries.removeAll { $0.content == content }
        entries.insert(Entry(timestamp: now(), content: content), at: 0)
        if entries.count > maxEntries {
            entries.removeLast(entries.count - maxEntries)
        }
    }

    /// Drop entries older than `maxAge`.
    public func prune() {
        let cutoff = now().addingTimeInterval(-maxAge)
        entries.removeAll { $0.timestamp < cutoff }
    }

    public func clear() {
        entries.removeAll()
    }
}
