# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

JSON Viewer is a native macOS application built with SwiftUI for viewing, formatting, and exploring JSON data. It has zero external dependencies — only Swift standard library and Apple frameworks (SwiftUI, AppKit, Foundation).

## Build Commands

```bash
# Build the app and create DMG installer
./build.sh
```

The build script cleans previous artifacts, compiles in Release configuration via `xcodebuild`, self-signs the binary (`CODE_SIGN_IDENTITY="-"`), and produces `build/JSONViewer.app` and `build/JSONViewer.dmg`.

There are no tests, linting, or package manager commands — the project uses only Xcode's build system.

## Requirements

- macOS 14+ (Sonoma)
- Xcode 15+ (Swift 5+)
- Target architecture: arm64 (Apple Silicon)

## Architecture

The app follows a straightforward SwiftUI pattern with three layers:

- **JSONViewerApp.swift** — App entry point. Single window group (1000x700).
- **ContentView.swift** — Main UI with an HSplitView: left panel is a JSON text editor (with beautify/minify), right panel shows the parsed tree or error. Parsing happens reactively via `onChange`.
- **JSONTreeView.swift** — Recursive tree renderer. `JSONNodeRow` renders each node and nests itself for children. Nodes are expandable/collapsible with color-coded types (blue keys, red strings, green numbers, orange booleans, gray null).
- **JSONNode.swift** — Data model. `JSONValue` enum covers all JSON types. `JSONNodeItem` wraps values into a tree structure with parent-child relationships. Parsing uses Foundation's `JSONSerialization` with `fragmentsAllowed`.

## Utilities

- **generate-icon.swift** — Programmatic icon generator using CoreGraphics. Outputs PNGs at all required resolutions to `JSONViewer/Assets.xcassets/AppIcon.appiconset/`.
- **build.sh** — Full build + DMG creation pipeline.
