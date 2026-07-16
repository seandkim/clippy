import AppKit
import ClipHistoryCore

/// Polls the general pasteboard's changeCount and feeds new content into the store.
final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private let reader = PasteboardReader()
    private let store: HistoryStore
    private var lastChangeCount: Int
    private var timer: Timer?

    /// Called after each tick so the UI can refresh if needed.
    var onChange: (() -> Void)?

    init(store: HistoryStore) {
        self.store = store
        self.lastChangeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        store.prune()
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount
        if let content = reader.read(from: pasteboard) {
            store.insert(content)
        }
        onChange?()
    }
}
