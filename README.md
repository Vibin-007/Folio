# Folio

A minimalist PDF viewer for Windows, built with Flutter. Your documents, beautifully read.

## Features

- **Dual view modes** — Single Page (with pinch-to-zoom & pan) and Continuous Scroll
- **Zoom controls** — Zoom in/out (0.25x–5.0x), Fit to Width, Fit to Page, reset to 100%
- **Full-text search** — Search across all pages with match navigation
- **Bookmarks** — Bookmark pages, manage them in the sidebar, persisted per file
- **Sidebar** — Thumbnail previews and bookmark list with animated toggle
- **Recent files** — Tracks last 10 opened PDFs, auto-open last file on launch
- **Fullscreen mode** — F11 toggle, floating auto-hiding toolbar
- **Light & Dark themes** — Toggle via toolbar or keyboard shortcut
- **Custom window chrome** — Native minimize/maximize/close with `window_manager`
- **Drag-and-drop** — Open PDFs by dropping them onto the app
- **Keyboard shortcuts** — Ctrl+O (open), Ctrl+F (search), arrow keys (navigate), and more
- **Persistent settings** — View mode, zoom, theme, last page per file via SharedPreferences

## Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| Ctrl+O | Open file |
| Ctrl+F | Open search |
| Escape | Close search / Exit fullscreen |
| F11 | Toggle fullscreen |
| → / Page Down | Next page |
| ← / Page Up | Previous page |
| Ctrl++ | Zoom in |
| Ctrl+- | Zoom out |
| Ctrl+0 | Reset zoom |
| Ctrl+W | Fit to width |
| Ctrl+B | Bookmark current page |
| Ctrl+T | Toggle theme |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Windows 10+

### Build & Run

```bash
flutter pub get
flutter run
```

To build a release executable:

```bash
flutter build windows --release
```

The built executable will be at `build\windows\x64\runner\Release\folio.exe`.

## Built With

- [Flutter](https://flutter.dev/) — UI framework
- [pdfx](https://pub.dev/packages/pdfx) — PDF rendering
- [Provider](https://pub.dev/packages/provider) — State management
- [SharedPreferences](https://pub.dev/packages/shared_preferences) — Local persistence
- [window_manager](https://pub.dev/packages/window_manager) — Native window controls
- [google_fonts](https://pub.dev/packages/google_fonts) — DM Sans, DM Serif Display, JetBrains Mono
- [file_picker](https://pub.dev/packages/file_picker) — Native file dialog
