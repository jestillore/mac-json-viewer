# JSON Viewer

A native macOS desktop app for viewing and formatting JSON. Paste or type JSON on the left, see an interactive tree view on the right.

## Features

- **Live JSON tree view** with collapsible/expandable nodes
- **Beautify** - pretty-print JSON with indentation
- **Minify** - compact JSON to a single line
- **Color-coded values** - strings, numbers, booleans, and null are color-coded for readability
- **Error feedback** - parse errors are shown inline

## Installation

1. Download `JSONViewer.dmg`
2. Open the DMG
3. Drag `JSONViewer.app` into the `Applications` folder
4. Eject the DMG

### Bypassing Gatekeeper

This app is self-signed, so macOS will block it on first launch. Use any of these methods to allow it:

#### Option 1: Right-click to open

Right-click (or Control-click) the app and select **Open**, then click **Open** in the confirmation dialog. You only need to do this once.

#### Option 2: System Settings

1. Try opening the app normally (it will be blocked)
2. Go to **System Settings > Privacy & Security**
3. Scroll down to find the message about JSONViewer being blocked
4. Click **Open Anyway**
5. Enter your password if prompted

#### Option 3: Remove the quarantine attribute

Open Terminal and run:

```
xattr -d com.apple.quarantine /Applications/JSONViewer.app
```

After any of these methods, the app will open normally from then on.

## Building from source

Requires Xcode and macOS 14+.

```
./build.sh
```

The built app and DMG will be in the `build/` directory.
