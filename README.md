# ClipBar

A tiny, dependency-free macOS menu bar clipboard history. Keeps the last 10
copies (max 1 hour) **in memory only** — nothing is written to disk.

## Build & run

```
swift test          # run the core unit tests
scripts/bundle.sh   # produce ClipBar.app
open ClipBar.app    # launch (📋 appears in the menu bar)
```

During development you can also just `swift run ClipBar` (Ctrl-C to stop).

## Use

Click the `📋` menu bar icon to see recent copies (newest first). Click one to
put it back on the clipboard. Password-manager copies show masked (`🔒 ••••••••`)
but still restore their real value. `Clear history` empties the list; `Quit` exits.

## Launch at login (optional)

```
scripts/install-login-item.sh
```

Removes with the command it prints.

## Scope

Memory only; text + images; last 10 / 60 min; no persistence, search, or settings.
