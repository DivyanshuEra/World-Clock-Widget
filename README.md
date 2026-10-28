# World Clock Widget for Windows

> A lightweight, movable, floating World Clock desktop widget built natively for Windows. Zero bloat, zero background daemons, 100% portable single-file executable.

---

## Features

- **100% Portable & Lightweight:** Single `.exe` (~270 KB) with embedded high-resolution icon. No installation, no admin rights required. Runs from any folder or USB drive.
- **Dynamic Live Clocks:** Displays real-time local times for multiple countries simultaneously with accurate Daylight Saving Time (DST) tracking.
- **Dual / Multi-Country Support:** Group countries sharing the same time zone together (e.g. `India/Sri Lanka`, `Turkey/Qatar`, `Germany/France`).
- **Smart Auto-Complete:** Automatically resolves capital cities, Windows timezone IDs, and standard offsets (IST, EDT, GST, CET, etc.) as you type.
- **Press & Drag Reordering:** Click and drag any country card up or down to reorder cards on the fly without awkward arrow buttons.
- **3-Sided Custom Window Resizing:** Resize the window smoothly from Left, Right, and Bottom borders. The top header remains dedicated for window dragging.
- **Always on Top & Minimize:** Pin on top toggle and an inward-arrows minimize button to keep out of your way.
- **Single-Instance Enforcement:** Launching the app automatically replaces any lingering stale instances, keeping memory clean.
- **Zero-Background Hotkey (`Ctrl + Alt + W`):** Launch on demand with a global keyboard shortcut without keeping any background service running.

---

## Quick Start

1. Download [`WorldClock.exe`](WorldClock.exe).
2. Double-click `WorldClock.exe` to run immediately.
3. *(Optional)* Run `CreateShortcut.bat` to create a Desktop shortcut with the `Ctrl + Alt + W` hotkey.

---

## Controls & Shortcuts

| Action | Control |
| :--- | :--- |
| **Move Window** | Press and drag anywhere on the top header (`World Clock`) |
| **Resize Window** | Drag the Left, Right, or Bottom window edges |
| **Reorder Clocks** | Press and hold any clock card, then drag up/down |
| **Edit Clock** | Double-click any clock card |
| **Add New Clock** | Click the `＋ Add Country` button at the bottom |
| **Toggle Always on Top** | Click the Pin button (`📌`) in the header |
| **Minimize** | Click the Inward-Arrows button (`🗕`) in the header |
| **Launch via Keyboard** | `Ctrl + Alt + W` (via Desktop shortcut) |

---

## Architecture & Tech Stack

- **Framework:** .NET 10.0 (WPF / C#)
- **Window Management:** Custom borderless `WindowChrome` with DWM hardware rendering.
- **Process Management:** Single-instance Win32 process lifecycle killer.
- **Storage:** Local portable JSON storage with automatic fallback to `%LocalAppData%`.
- **Packaging:** Native single-file compilation with embedded multi-resolution `.ico` assets.

---

## Credits & Authorship

- **Architect & Product Lead:** [Divyanshu Era](https://github.com/DivyanshuEra) — *Concept, UX/UI Specifications, Edge-case Testing & Quality Assurance.*
- **Pair Programming:** Google DeepMind [Antigravity IDE](https://deepmind.google/)

---

## License

This project is open-source and released under the [MIT License](LICENSE).
