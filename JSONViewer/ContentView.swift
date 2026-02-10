import SwiftUI

struct ContentView: View {
    @State private var jsonText: String = "{\n  \"name\": \"JSON Viewer\",\n  \"version\": 1.0,\n  \"features\": [\"parse\", \"beautify\", \"minify\"],\n  \"nested\": {\n    \"enabled\": true,\n    \"count\": 42\n  }\n}"
    @State private var parsedValue: JSONValue?
    @State private var errorMessage: String?

    var body: some View {
        HSplitView {
            leftPanel
                .frame(minWidth: 300)

            rightPanel
                .frame(minWidth: 300)
        }
        .frame(minWidth: 700, minHeight: 400)
        .onAppear { parseJSON() }
    }

    private var leftPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("JSON Input")
                    .font(.headline)

                Spacer()

                Button("Beautify") { beautify() }
                    .buttonStyle(.bordered)

                Button("Minify") { minify() }
                    .buttonStyle(.bordered)
            }
            .padding(12)

            Divider()

            TextEditor(text: $jsonText)
                .font(.system(.body, design: .monospaced))
                .scrollContentBackground(.visible)
                .onChange(of: jsonText) { parseJSON() }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private var rightPanel: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Tree View")
                    .font(.headline)

                Spacer()

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(12)

            Divider()

            if let parsedValue {
                JSONTreeView(rootValue: parsedValue)
            } else {
                VStack {
                    Spacer()
                    Text("Enter valid JSON on the left to see the tree view")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    private func parseJSON() {
        let trimmed = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            parsedValue = nil
            errorMessage = nil
            return
        }

        guard let data = trimmed.data(using: .utf8) else {
            parsedValue = nil
            errorMessage = "Invalid encoding"
            return
        }

        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            parsedValue = JSONValue.from(obj)
            errorMessage = nil
        } catch {
            parsedValue = nil
            errorMessage = error.localizedDescription
        }
    }

    private func beautify() {
        let trimmed = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else { return }

        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let prettyData = try JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys])
            if let prettyString = String(data: prettyData, encoding: .utf8) {
                jsonText = prettyString
            }
        } catch {
            // JSON is invalid, don't modify
        }
    }

    private func minify() {
        let trimmed = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = trimmed.data(using: .utf8) else { return }

        do {
            let obj = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let compactData = try JSONSerialization.data(withJSONObject: obj, options: [.sortedKeys])
            if let compactString = String(data: compactData, encoding: .utf8) {
                jsonText = compactString
            }
        } catch {
            // JSON is invalid, don't modify
        }
    }
}
