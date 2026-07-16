import AppKit

public extension ClipContent {
    /// A menu-sized image for `.image` content, scaled to `maxHeight` (aspect-preserving).
    /// Returns nil for non-image content. Only sets the display size — no offscreen render,
    /// so this is safe to call headlessly.
    func thumbnailImage(maxHeight: CGFloat = 16) -> NSImage? {
        guard case .image(let data, let w, let h) = self,
              let image = NSImage(data: data) else { return nil }
        let scale = maxHeight / CGFloat(max(h, 1))
        image.size = NSSize(width: CGFloat(w) * scale, height: maxHeight)
        return image
    }
}
