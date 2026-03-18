import AppKit

enum CompactPanelLayout {
    static let width: CGFloat = 380
    static let fallbackHeight: CGFloat = 480
    static let margin: CGFloat = 10

    static func height(for screen: NSScreen?, size: CompactPanelSize) -> CGFloat {
        guard let screen else { return fallbackHeight }

        let visibleHeight = max(0, screen.visibleFrame.height - margin * 2)
        let targetHeight = screen.frame.height * size.heightRatio
        return min(targetHeight, visibleHeight)
    }
}
