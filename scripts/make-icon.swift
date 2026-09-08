// Renders Resources/Clippy.icns: white SF Symbol paperclip on an indigo->blue
// squircle. Each size is drawn natively so the glyph stays crisp at 16pt.
// Usage: swift scripts/make-icon.swift   (run from the repo root)
import AppKit

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let fm = FileManager.default
let iconset = "Resources/Clippy.iconset"
try? fm.removeItem(atPath: iconset)
try fm.createDirectory(atPath: iconset, withIntermediateDirectories: true)

func newRep(_ px: Int) -> NSBitmapImageRep {
    NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px,
                     bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                     isPlanar: false, colorSpaceName: .deviceRGB,
                     bytesPerRow: 0, bitsPerPixel: 0)!
}

func draw(into rep: NSBitmapImageRep, _ body: () -> Void) {
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current?.imageInterpolation = .high
    body()
    NSGraphicsContext.restoreGraphicsState()
}

/// A white paperclip cropped to its own ink. SF Symbol images include baseline
/// and leading padding, so centering the raw image box leaves the glyph visibly
/// low and to the right — we crop to actual alpha bounds and center on that.
func whitePaperclip(pointSize: CGFloat) -> CGImage? {
    let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .medium)
    guard let symbol = NSImage(systemSymbolName: "paperclip", accessibilityDescription: nil)?
        .withSymbolConfiguration(config) else { return nil }

    let px = Int(max(symbol.size.width, symbol.size.height).rounded(.up)) + 4
    let rep = newRep(px)
    draw(into: rep) {
        let box = NSRect(x: (CGFloat(px) - symbol.size.width) / 2,
                         y: (CGFloat(px) - symbol.size.height) / 2,
                         width: symbol.size.width, height: symbol.size.height)
        // Tint inside a transparent image: .sourceAtop there only paints where
        // the glyph has alpha. Doing it on the opaque gradient floods the rect.
        let white = NSImage(size: symbol.size, flipped: false) { r in
            symbol.draw(in: r)
            NSColor.white.set()
            r.fill(using: .sourceAtop)
            return true
        }
        white.draw(in: box)
    }

    guard let full = rep.cgImage, let data = rep.bitmapData else { return nil }
    let stride = rep.bytesPerRow, spp = rep.samplesPerPixel
    var minX = px, minY = px, maxX = -1, maxY = -1
    for y in 0..<px {
        for x in 0..<px where data[y * stride + x * spp + 3] > 8 {
            if x < minX { minX = x }; if x > maxX { maxX = x }
            if y < minY { minY = y }; if y > maxY { maxY = y }
        }
    }
    guard maxX >= minX, maxY >= minY else { return nil }
    return full.cropping(to: CGRect(x: minX, y: minY,
                                    width: maxX - minX + 1, height: maxY - minY + 1))
}

/// Draws one square icon. `canvas` is the full pixel box; the squircle is inset
/// to Apple's macOS grid (824/1024), leaving the usual shadow room.
func render(canvas: CGFloat) -> NSBitmapImageRep {
    let rep = newRep(Int(canvas))
    draw(into: rep) {
        let art = (canvas * 824.0 / 1024.0).rounded()
        let origin = ((canvas - art) / 2).rounded()
        let box = NSRect(x: origin, y: origin, width: art, height: art)

        let squircle = NSBezierPath(roundedRect: box,
                                    xRadius: art * 0.2237, yRadius: art * 0.2237)
        let gradient = NSGradient(colors: [
            NSColor(srgbRed: 0.36, green: 0.31, blue: 0.87, alpha: 1),   // indigo
            NSColor(srgbRed: 0.13, green: 0.53, blue: 0.96, alpha: 1),   // blue
        ])!
        gradient.draw(in: squircle, angle: -60)

        let fit = art * 0.54
        guard let glyph = whitePaperclip(pointSize: max(fit, 24)) else { return }
        let gw = CGFloat(glyph.width), gh = CGFloat(glyph.height)
        let scale = min(fit / gw, fit / gh)
        let size = NSSize(width: gw * scale, height: gh * scale)
        let target = NSRect(x: box.midX - size.width / 2,
                            y: box.midY - size.height / 2,
                            width: size.width, height: size.height)
        NSGraphicsContext.current?.cgContext.draw(glyph, in: target)
    }
    return rep
}

// (pixel size, iconset filename)
let variants: [(CGFloat, String)] = [
    (16, "icon_16x16.png"),     (32, "icon_16x16@2x.png"),
    (32, "icon_32x32.png"),     (64, "icon_32x32@2x.png"),
    (128, "icon_128x128.png"),  (256, "icon_128x128@2x.png"),
    (256, "icon_256x256.png"),  (512, "icon_256x256@2x.png"),
    (512, "icon_512x512.png"),  (1024, "icon_512x512@2x.png"),
]

for (size, name) in variants {
    guard let png = render(canvas: size).representation(using: .png, properties: [:]) else {
        fatalError("failed to encode \(name)")
    }
    try png.write(to: URL(fileURLWithPath: "\(iconset)/\(name)"))
}
print("Wrote \(iconset)")
