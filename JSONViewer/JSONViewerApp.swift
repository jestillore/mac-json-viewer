import SwiftUI

@main
struct JSONViewerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .defaultSize(width: 1000, height: 700)
        .commands {
            CommandGroup(after: .newItem) {
                Button("Import File...") {
                    appState.isImporting = true
                }
                .keyboardShortcut("o", modifiers: .command)
            }
        }
    }
}
