import SwiftUI
import AppKit

struct HighlightedTextEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        let textView = NSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.usesFindPanel = true
        textView.font = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.drawsBackground = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false

        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true

        textView.textStorage?.delegate = context.coordinator

        scrollView.documentView = textView
        context.coordinator.textView = textView

        // Set initial text and apply highlighting
        context.coordinator.isUpdating = true
        textView.string = text
        applyHighlighting(to: textView)
        context.coordinator.isUpdating = false

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text && !context.coordinator.isUpdating {
            context.coordinator.isUpdating = true
            let selectedRanges = textView.selectedRanges
            textView.string = text
            applyHighlighting(to: textView)
            textView.selectedRanges = selectedRanges
            context.coordinator.isUpdating = false
        }
    }

    private func applyHighlighting(to textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let source = textView.string
        let fullRange = NSRange(location: 0, length: (source as NSString).length)

        textStorage.beginEditing()
        textStorage.removeAttribute(.foregroundColor, range: fullRange)
        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize, weight: .regular), range: fullRange)

        let tokens = tokenizeJSON(source)
        for token in tokens {
            guard token.range.location + token.range.length <= fullRange.length else { continue }
            let color: NSColor
            switch token.type {
            case .objectKey: color = NSColor.systemBlue
            case .string:    color = NSColor.systemRed
            case .number:    color = NSColor.systemGreen
            case .bool:      color = NSColor.systemOrange
            case .null:      color = NSColor.systemGray
            case .punctuation: continue
            }
            textStorage.addAttribute(.foregroundColor, value: color, range: token.range)
        }
        textStorage.endEditing()
    }

    class Coordinator: NSObject, NSTextStorageDelegate {
        var parent: HighlightedTextEditor
        var textView: NSTextView?
        var isUpdating = false

        init(_ parent: HighlightedTextEditor) {
            self.parent = parent
        }

        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard !isUpdating, editedMask.contains(.editedCharacters) else { return }
            isUpdating = true
            let newText = textStorage.string
            DispatchQueue.main.async { [self] in
                parent.text = newText
                if let textView = textView {
                    parent.applyHighlighting(to: textView)
                }
                isUpdating = false
            }
        }
    }
}
