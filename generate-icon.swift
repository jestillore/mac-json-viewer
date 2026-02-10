import AppKit

func generateIcon(size: Int) -> NSImage {
    let s = CGFloat(size)
    let image = NSImage(size: NSSize(width: s, height: s))
    image.lockFocus()

    let context = NSGraphicsContext.current!.cgContext

    // Background rounded rect
    let cornerRadius = s * 0.2
    let bgRect = CGRect(x: 0, y: 0, width: s, height: s)
    let bgPath = CGPath(roundedRect: bgRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)

    // Gradient background
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let gradientColors = [
        CGColor(red: 0.18, green: 0.22, blue: 0.32, alpha: 1.0),
        CGColor(red: 0.10, green: 0.13, blue: 0.20, alpha: 1.0),
    ] as CFArray
    let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!

    context.saveGState()
    context.addPath(bgPath)
    context.clip()
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: s), end: CGPoint(x: 0, y: 0), options: [])
    context.restoreGState()

    // Draw "{ }" text
    let fontSize = s * 0.45
    let font = NSFont.systemFont(ofSize: fontSize, weight: .bold)
    let braceAttrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0.40, green: 0.85, blue: 1.0, alpha: 1.0),
    ]

    let braceStr = NSAttributedString(string: "{ }", attributes: braceAttrs)
    let braceSize = braceStr.size()
    let braceX = (s - braceSize.width) / 2
    let braceY = (s - braceSize.height) / 2 + s * 0.08

    braceStr.draw(at: NSPoint(x: braceX, y: braceY))

    // Draw small colored dots to represent JSON values
    let dotRadius = s * 0.035
    let dotY = s * 0.28
    let dotSpacing = s * 0.12
    let centerX = s / 2

    let dotColors: [NSColor] = [
        NSColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1.0), // red - string
        NSColor(red: 0.45, green: 0.9, blue: 0.45, alpha: 1.0),  // green - number
        NSColor(red: 1.0, green: 0.75, blue: 0.3, alpha: 1.0),  // orange - bool
    ]

    for (i, color) in dotColors.enumerated() {
        let offset = CGFloat(i - 1) * dotSpacing
        let dotRect = CGRect(
            x: centerX + offset - dotRadius,
            y: dotY - dotRadius,
            width: dotRadius * 2,
            height: dotRadius * 2
        )
        color.setFill()
        NSBezierPath(ovalIn: dotRect).fill()
    }

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG for \(path)")
        return
    }
    do {
        try png.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path)")
    } catch {
        print("Error saving \(path): \(error)")
    }
}

let sizes: [(points: Int, scale: Int)] = [
    (16, 1), (16, 2),
    (32, 1), (32, 2),
    (128, 1), (128, 2),
    (256, 1), (256, 2),
    (512, 1), (512, 2),
]

let outputDir = "JSONViewer/Assets.xcassets/AppIcon.appiconset"

for entry in sizes {
    let px = entry.points * entry.scale
    let image = generateIcon(size: px)
    let filename = "icon_\(entry.points)x\(entry.points)@\(entry.scale)x.png"
    savePNG(image, to: "\(outputDir)/\(filename)")
}

print("Done!")
