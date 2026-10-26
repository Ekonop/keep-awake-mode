# Performance Keep-Awake for KDE Plasma 6

A special **"Keep Awake" energy mode** for Plasma 6: switch to the `performance`
power profile while keeping the desktop fully running — sleep / lid switch and
PowerDevil auto-suspend are blocked, the display may blank as normal, but the
screen **never auto-locks**, so hotspot, downloads and background tasks keep
running until you switch the mode off.

- ON: `powerprofilesctl set performance` → **plus** a `systemd-inhibit` block on
  `sleep` and `handle-lid-switch`, wrapped around `kde-inhibit --power`
  (no PowerDevil auto-suspend). Display blanking is **not** inhibited.
- ON also temporarily suppresses both Plasma lock paths so a blanked screen
  stays **unlocked**: PowerDevil's `LockBeforeTurnOffDisplay` (AC / Battery /
  LowBattery profiles) and the KScreenLocker `[Daemon] Autolock` idle lock.
  Both daemons reload live (`refreshStatus` / `configure`).
- OFF: removes the inhibitor, restores the previously active energy profile **and**
  the exact lock settings that were in effect before ON.
- The stock `performance` profile and your PowerDevil settings are **never
  modified** — this is a composed mode on top of them.

Also ships a **battery applet fork** (`vansh.keepawake.battery`) that puts a
4th "Keep Awake" stop in the popup's mode slider next to
Performance / Balanced / Power Saver.

## How it works

```
systemd-run --user --unit=keep-awake-inhibit --collect \
    systemd-inhibit --what=sleep:handle-lid-switch --mode=block \
    kde-inhibit --power sleep infinity
```

`sleep infinity` is the **hold-open child**: `systemd-inhibit` releases its lock
the moment the child exits, so the child must keep running for the inhibitor to
stay alive. `systemd-run` makes the whole chain a managed transient unit, so
`systemctl --user stop keep-awake-inhibit` reliably kills it.

**Why the lock is suppressed separately:** in Plasma 6 the screen can blank
without the session sleeping — but two independent lock paths fire on idle
(PowerDevil's lock-before-display-off, and the KScreenLocker idle autolock).
While the mode is ON, `keep-awake-mode` writes `LockBeforeTurnOffDisplay=false`
into the AC/Battery/LowBattery Display sections of `powerdevilrc` and
`Autolock=false` into `kscreenlockerrc`, then tells PowerDevil and the screen
locker to reload live. The previous values are remembered in
`~/.local/state/keep-awake-mode/state` and restored when the mode turns OFF.
State (previous profile + lock settings) is kept per-session (transient unit
dies at logout).

## Installation

### Arch (PKGBUILD)

```sh
cd keep-awake-mode
makepkg -si
```

This installs:

- `/usr/bin/keep-awake-mode`
- `/usr/share/plasma/plasmoids/vansh.keepawake.battery/`
- `/usr/share/applications/keep-awake-mode.desktop` (launcher "Performance Keep-Awake")

An [AUR](https://aur.archlinux.org) submission is prepared (`.SRCINFO`-ready
PKGBUILD + `./aur-submit.sh`), but AUR temporarily paused new account
registration (HTTP 503), so it is not published yet. Once registration
reopens: `./aur-submit.sh` publishes it, after which
`yay -S keep-awake-mode` will work.

### Any distro (user-local, no root)

```sh
git clone https://github.com/Ekonop/keep-awake-mode
cd keep-awake-mode
./install.sh            # installs to ~/.local/bin, ~/.local/share/plasma/plasmoids, ~/.local/share/applications
```

## Using it

```sh
keep-awake-mode on                  # enable
keep-awake-mode off                 # disable, restore previous profile
keep-awake-mode toggle              # flip it
keep-awake-mode status              # human-readable
keep-awake-mode state               # prints exactly ON or OFF (for widgets/scripts)
keep-awake-mode tray-status         # which battery applet the tray hosts
```

There is also a launcher in your application menu ("Performance Keep-Awake")
that toggles with a single click.

## Replacing the stock tray battery with the Keep-Awake one

> **Recommended: manual, via the Plasma UI** — this is the most robust way and
> survives Plasma upgrades. The `tray-*` subcommands below automate the same
> thing but edit `~/.config/plasma-org.kde.plasma.desktop-appletsrc` directly.

1. In the system tray, right-click the battery icon → **Configure System Tray…**
   (or right-click the tray → Configure system tray).
2. In the settings dialog, find the **Battery** entry and uncheck / remove it so
   the stock battery icon disappears from the tray.
3. Right-click the panel → **Add Widgets…** → search for
   **"Power & Battery (Keep-Awake)"** → add it.
4. Drag it next to the system tray. Click it — the popup opens with the normal
   battery info, and under **Mode** you now see:

   **Performance · Balanced · Power Saver · Keep Awake**

5. Slide the pointer to **Keep Awake**: the desktop stays fully awake on AC —
   performance profile, sleep/lid and PowerDevil auto-suspend are blocked, the
   display may blank as usual but the screen never auto-locks (PowerDevil
   lock-before-display-off and the KScreenLocker idle lock are suppressed for
   the duration; both are restored when you leave the stop). Slide to any other
   stop to leave Keep-Awake.

> The applet is a fork of the stock Plasma battery applet with an extra slider
> stop; it also advertises `X-Plasma-Provides: org.kde.plasma.battery`, so it is
> offered as an *alternative* to the stock applet where Plasma shows such lists
> (e.g. "Alternatives…" context menus).

### Scripted alternative

```sh
keep-awake-mode tray-enable     # swap stock battery <-> vansh.keepawake.battery in the tray
keep-awake-mode tray-disable    # restore stock
```

These edit the appletsrc and restart plasmashell. If anything looks off, restore
with `tray-disable` (a backup of the pre-swap file is kept at
`~/.config/plasma-org.kde.plasma.desktop-appletsrc.keepawake.bak`).

## Notes & limitations

- **Plasma 6.6+ (KDE bug 516460)** blocks user-level *shadowing* of compiled
  system applets, so this project does **not** try to shadow
  `org.kde.plasma.battery` under the same plugin id — it ships a fork under its
  own id (`vansh.keepawake.battery`) plus `X-Plasma-Provides`.
- Requires `power-profiles-daemon` (or compatible `powerprofilesctl`) for the
  profile switch and `systemd` for the inhibitor. While Keep-Awake is ON the
  screen-lock settings described above are temporarily disabled; when the mode
  is turned OFF, the exact previous values (including "unset") are restored.
- Keep-Awake is per-session by design: it does not survive a reboot.

## Uninstall

```sh
./uninstall.sh               # user-local install
# or
sudo pacman -R keep-awake-mode   # PKGBUILD install
keep-awake-mode tray-disable # put the stock battery back if you had swapped it
```

## License

- `keep-awake-mode` script: **MIT** (see `LICENSE`).
- The bundled plasmoid QML is derived from KDE's battery applet
  (SPDX-License-Identifier: LGPL-2.0-or-later) as shipped by
  [powerdevil](https://invent.kde.org/plasma/powerdevil) — see
  `plasmoid/…/contents/ui/*.qml` headers.