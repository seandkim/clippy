import AppKit
import ClipHistoryCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = HistoryStore()
    private var monitor: ClipboardMonitor?
    private var menuController: MenuController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuController = MenuController(store: store)
        let monitor = ClipboardMonitor(store: store)
        monitor.start()
        self.monitor = monitor
    }
}
