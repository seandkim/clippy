import Testing
import Foundation
import ClipHistoryCore

struct ClipContentTests {
    @Test func textPreviewCollapsesWhitespaceAndTrims() {
        #expect(ClipContent.text("  hello\n\n  world  ").previewText == "hello world")
    }

    @Test func longTextPreviewIsTruncatedWithEllipsis() {
        let long = String(repeating: "a", count: 100)
        let preview = ClipContent.text(long).previewText
        #expect(preview.count <= 50)
        #expect(preview.hasSuffix("…"))
    }

    @Test func imagePreviewShowsDimensions() {
        #expect(ClipContent.image(data: Data(), width: 320, height: 240).previewText == "Image 320×240")
    }

    @Test func concealedPreviewIsMasked() {
        #expect(ClipContent.concealed(text: "s3cret").previewText == "🔒 ••••••••")
    }
}
