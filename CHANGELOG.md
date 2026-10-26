# Changelog

All notable changes to **keep-awake-mode** are tracked here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and semantic
versioning.

## [1.0.1] — 2026-10-27

### Added
- `CHANGELOG.md` (this file).
- AUR-compliant `PKGBUILD` (git source pinned to a release tag, `.SRCINFO`
  generated via `makepkg --printsrcinfo`) and `aur-submit.sh` to publish the
  package to the Arch User Repository once registration reopens.
- `check.sh`: quick syntax / metadata sanity check for the repository.

### Changed
- `keep-awake-mode tray-status` no longer prints a stray `0` when the stock
  battery is active (grep `-c || echo 0` artifact).
- Script path in the QML is resolved portably (plasmoid config `command` key →
  PATH lookup) instead of a hardcoded `/home/vansh/…`; `Qt.EnvironmentVariable`
  was found **not** to be a QML-facing API in this Qt version, so it is not used.

### Fixed
- `tray-enable`'s Python config writer crashed on the appletsrc regex
  (Python 3.14 `re` error); replaced with a line-based editor that anchors to
  the correct applet instance.

## [1.0.0] — 2026-10-27

### Added
- `keep-awake-mode` script: **Performance Keep-Awake** special mode for KDE
  Plasma 6 (MIT).
  - ON: `powerprofilesctl set performance` + `systemd-inhibit` block on
    `sleep` and `handle-lid-switch`; display turn-off is *not* inhibited, so
    the panel can still blank.
  - OFF: removes the inhibitor and restores the previously active profile.
  - Subcommands: `on`, `off [profile]`, `toggle`, `status`, `state`,
    `tray-enable`, `tray-disable`, `tray-status`.
  - State in `~/.local/state/keep-awake-mode/state`; managed via the
    transient user unit `keep-awake-inhibit` (per-session by design).
- `vansh.keepawake.battery` Plasma applet (LGPL-2.0-or-later): fork of the
  stock Plasma battery applet with a 4th **Keep Awake** stop in the popup's
  mode slider.
- Manual tray-replacement instructions in `README.md` (hide stock battery in
  the system-tray settings, add the fork via *Add Widgets*).
- `PKGBUILD`, `install.sh` / `uninstall.sh` (user-local, no root), launcher
  `applications/keep-awake-mode.desktop`.
- Published to GitHub (public) with a built `pkg.tar.zst` release artifact.

[1.0.1]: https://github.com/Ekonop/keep-awake-mode/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/Ekonop/keep-awake-mode/releases/tag/v1.0.0