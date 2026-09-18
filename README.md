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

This installs a released binary. Building from source would pull the whole Rust
toolchain onto the machine as a build dependency and leave it there, which is a
poor trade for a four-hundred-kilobyte program. If you would rather build it
anyway:

```sh
brew install --HEAD wertcore/tap/klart
```

which is where the Rust dependency lives — asked for rather than imposed.

### What runs where

| | |
| --- | --- |
| macOS | the agent and the command line, on Apple silicon, run on real hardware |
| Linux | the command line, x86_64; compiled and tested by CI, never yet run |

Intel Macs are not supported and not merely unbuilt: the registry walk that finds
a monitor's name and its I2C channel matches a class they do not publish. aarch64
Linux has no published build yet; `--HEAD` makes one.

On Linux, external monitors want read and write on `/dev/i2c-*` — usually the
`i2c` group or a udev rule — and the panel wants write access to
`/sys/class/backlight/*/brightness`. `klart probe` says which mechanism reached
which display and why the others did not.

## Why a tap and not homebrew-core

Homebrew's own repository has notability requirements a new project does not
meet. This is the same formula it would be there.
