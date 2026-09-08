# Clippy

A tiny, dependency-free macOS menu bar clipboard history. Keeps the last 10
copies (max 1 hour) **in memory only** — nothing is written to disk.

## Install

```
scripts/install.sh              # build + copy the bundle to /Applications
scripts/install-login-item.sh   # optional: launch at login
```

`install.sh` copies the real bundle rather than symlinking it. A symlink in
`/Applications` does not work — LaunchServices resolves it and registers the
repo path, so the app never shows up in the Applications view.

Removing the login item: run `install-login-item.sh` and use the command it
prints.

## Develop

```
swift test          # run the core unit tests
scripts/bundle.sh   # produce Clippy.app in the repo, without installing
swift run Clippy    # run straight from source (Ctrl-C to stop)
```

## Use

Click the `📎` menu bar icon to see recent copies (newest first). Click one to
put it back on the clipboard. Password-manager copies show masked (`🔒 ••••••••`)
but still restore their real value. `Clear history` empties the list; `Quit` exits.

## The app icon

`Resources/Clippy.icns` is committed, so a normal build needs nothing. To change
the design, edit `scripts/make-icon.swift` and regenerate:

```
swift scripts/make-icon.swift
iconutil -c icns Resources/Clippy.iconset -o Resources/Clippy.icns
rm -rf Resources/Clippy.iconset
```

It draws a white SF Symbol paperclip on an indigo→blue squircle, rendering each
size natively instead of downscaling one master.

## Scope

Memory only; text + images; last 10 / 60 min; no persistence, search, or settings.
