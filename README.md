# WertCore tap

Homebrew formulae for [WertCore](https://github.com/WertCore) projects.

## klart

Brightness for every display attached to the machine — the built-in panel and
external monitors alike, from the menu bar or the command line.

```sh
brew install wertcore/tap/klart
```

That installs the `klart` command line. On macOS it also installs `klart-tray`,
the menu bar agent, which you can have start with your session:

```sh
brew services start klart
```

Worth starting if any display falls back to the gamma ramp — macOS reverts a ramp
when the process that set it exits, so such a display returns to full brightness
after every restart unless something is holding it. `klart list` marks those with
a `*`.

Built from source, which also means the binaries are yours rather than an
unsigned download macOS would quarantine.

### What runs where

| | |
| --- | --- |
| macOS | the agent and the command line, run on real hardware |
| Linux | the command line; compiled and tested by CI, never yet run |

On Linux, external monitors want read and write on `/dev/i2c-*` — usually the
`i2c` group or a udev rule — and the panel wants write access to
`/sys/class/backlight/*/brightness`. `klart probe` says which mechanism reached
which display and why the others did not.

## Why a tap and not homebrew-core

Homebrew's own repository has notability requirements a new project does not
meet. This is the same formula it would be there.
