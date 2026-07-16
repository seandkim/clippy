import Testing
import Foundation
import ClipHistoryCore

private final class Clock {
    var now: Date
    init(_ d: Date) { now = d }
}

struct HistoryStoreTests {
    private func makeStore(_ clock: Clock, maxEntries: Int = 10, maxAge: TimeInterval = 3600) -> HistoryStore {
        HistoryStore(maxEntries: maxEntries, maxAge: maxAge, now: { clock.now })
    }

    @Test func countCapKeepsNewestN() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let store = makeStore(clock, maxEntries: 10)
        for i in 0..<12 { store.insert(.text("\(i)")) }
        #expect(store.entries.count == 10)
        #expect(store.entries.first?.content == .text("11"))
        #expect(store.entries.last?.content == .text("2"))
    }

    @Test func dedupMovesExistingToTop() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let store = makeStore(clock)
        store.insert(.text("A"))
        store.insert(.text("B"))
        store.insert(.text("A"))
        #expect(store.entries.count == 2)
        #expect(store.entries.map(\.content) == [.text("A"), .text("B")])
    }

    @Test func dedupRefreshesTimestamp() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let store = makeStore(clock)
        store.insert(.text("A"))
        clock.now = clock.now.addingTimeInterval(10)
        store.insert(.text("A"))
        #expect(store.entries.first?.timestamp == Date(timeIntervalSinceReferenceDate: 10))
    }

    @Test func pruneDropsEntriesOlderThanMaxAge() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let store = makeStore(clock, maxAge: 3600)
        store.insert(.text("old"))                      // t=0
        clock.now = clock.now.addingTimeInterval(1800)
        store.insert(.text("recent"))                   // t=1800
        clock.now = clock.now.addingTimeInterval(1900)  // t=3700
        store.prune()
        #expect(store.entries.map(\.content) == [.text("recent")])
    }

    @Test func clearEmptiesHistory() {
        let clock = Clock(Date(timeIntervalSinceReferenceDate: 0))
        let store = makeStore(clock)
        store.insert(.text("A"))
        store.clear()
        #expect(store.entries.isEmpty)
    }
}
