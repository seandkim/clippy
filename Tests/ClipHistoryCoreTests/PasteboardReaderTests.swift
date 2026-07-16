import Testing
import Foundation
import AppKit
import ClipHistoryCore

struct PasteboardReaderTests {
    private let concealedType = NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType")

    private func scratchPasteboard() -> NSPasteboard {
        NSPasteboard(name: NSPasteboard.Name("clippy-test-\(UUID().uuidString)"))
    }

    private func tinyPNG(w: Int, h: Int) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w, pixelsHigh: h,
                                   bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                   isPlanar: false, colorSpaceName: .deviceRGB,
                                   bytesPerRow: 0, bitsPerPixel: 0)!
        return rep.representation(using: .png, properties: [:])!
    }

    @Test func readPlainText() {
        let pb = scratchPasteboard()
        pb.clearContents()
        pb.setString("hello", forType: .string)
        #expect(PasteboardReader().read(from: pb) == .text("hello"))
    }

    @Test func readConcealedText() {
        let pb = scratchPasteboard()
        pb.clearContents()
        pb.setString("s3cret", forType: .string)
        pb.setData(Data(), forType: concealedType)
        #expect(PasteboardReader().read(from: pb) == .concealed(text: "s3cret"))
    }

    @Test func readImageCapturesPixelDimensions() {
        let pb = scratchPasteboard()
        pb.clearContents()
        pb.setData(tinyPNG(w: 2, h: 3), forType: .png)
        guard case .image(_, let w, let h)? = PasteboardReader().read(from: pb) else {
            Issue.record("expected image content")
            return
        }
        #expect(w == 2)
        #expect(h == 3)
    }

    @Test func readEmptyReturnsNil() {
        let pb = scratchPasteboard()
        pb.clearContents()
        #expect(PasteboardReader().read(from: pb) == nil)
    }

    @Test func writeTextRoundTrips() {
        let pb = scratchPasteboard()
        PasteboardReader().write(.text("hi"), to: pb)
        #expect(pb.string(forType: .string) == "hi")
    }

    @Test func writeConcealedReTagsSoItStaysMasked() {
        let pb = scratchPasteboard()
        let reader = PasteboardReader()
        reader.write(.concealed(text: "pw"), to: pb)
        #expect(pb.string(forType: .string) == "pw")
        #expect(pb.data(forType: concealedType) != nil)
        // Round-trip: re-reading keeps it concealed, not plaintext.
        #expect(reader.read(from: pb) == .concealed(text: "pw"))
    }

    @Test func thumbnailForImageIsSizedAndNonNil() {
        let content = ClipContent.image(data: tinyPNG(w: 8, h: 4), width: 8, height: 4)
        let thumb = content.thumbnailImage(maxHeight: 16)
        #expect(thumb != nil)
        #expect(thumb?.size.height == 16)
    }

    @Test func thumbnailNilForNonImage() {
        #expect(ClipContent.text("x").thumbnailImage() == nil)
        #expect(ClipContent.concealed(text: "x").thumbnailImage() == nil)
    }
}
