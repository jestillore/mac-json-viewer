import SwiftUI

struct JSONTreeView: View {
    let rootValue: JSONValue

    var body: some View {
        let rootNode = JSONNodeItem(key: nil, index: nil, value: rootValue)
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let children = rootNode.children {
                    ForEach(children) { child in
                        JSONNodeRow(node: child, depth: 0)
                    }
                } else {
                    JSONNodeRow(node: rootNode, depth: 0)
                }
            }
            .padding(12)
        }
    }
}

struct JSONNodeRow: View {
    let node: JSONNodeItem
    let depth: Int
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                if node.value.isContainer {
                    Button(action: { withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer()
                        .frame(width: 16)
                }

                Text(node.label)
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(keyColor)

                if !node.value.isContainer {
                    Text(":")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.secondary)

                    Text(node.value.displayValue)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(valueColor)
                        .textSelection(.enabled)
                } else {
                    Text(node.value.displayValue)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, CGFloat(depth) * 20)
            .padding(.vertical, 3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                if node.value.isContainer {
                    withAnimation(.easeInOut(duration: 0.15)) { isExpanded.toggle() }
                }
            }

            if isExpanded, let children = node.children {
                ForEach(children) { child in
                    JSONNodeRow(node: child, depth: depth + 1)
                }
            }
        }
    }

    private var keyColor: Color {
        if node.index != nil {
            return .purple
        }
        return .blue
    }

    private var valueColor: Color {
        switch node.value {
        case .string: return .red
        case .number: return .green
        case .bool: return .orange
        case .null: return .gray
        default: return .primary
        }
    }
}
