import AppKit
import ClipHistoryCore

/// Owns the menu bar status item and rebuilds the dropdown on open.
final class MenuController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let store: HistoryStore
    private let reader = PasteboardReader()

    init(store: HistoryStore) {
        self.store = store
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        if let button = statusItem.button {
            // Native monochrome menu-bar glyph that adapts to light/dark.
            if let image = NSImage(systemSymbolName: "paperclip",
                                   accessibilityDescription: "Clippy clipboard history") {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "📎" // fallback if the SF Symbol is unavailable
            }
        }
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        store.prune()
        menu.removeAllItems()

        if store.entries.isEmpty {
            let empty = NSMenuItem(title: "No clipboard history", action: nil, keyEquivalent: "")
            empty.isEnabled = false
            menu.addItem(empty)
        } else {
            for entry in store.entries {
                let item = NSMenuItem(title: entry.content.previewText,
                                      action: #selector(restore(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = entry.id
                item.image = entry.content.thumbnailImage(maxHeight: 16)
                menu.addItem(item)
            }
        }

        menu.addItem(.separator())

        let clear = NSMenuItem(title: "Clear history", action: #selector(clearHistory), keyEquivalent: "")
        clear.target = self
        menu.addItem(clear)

        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
    }

    @objc private func restore(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID,
              let entry = store.entries.first(where: { $0.id == id }) else { return }
        reader.write(entry.content, to: .general)
    }

    @objc private func clearHistory() {
        store.clear()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
