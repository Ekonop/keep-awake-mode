#!/usr/bin/env bash
# One-shot AUR submission helper (run AFTER AUR registration reopens):
#   1. generates .SRCINFO
#   2. clones the (empty) AUR repo via SSH
#   3. copies PKGBUILD + .SRCINFO + optional AUX files
#   4. commits and pushes
#
# Prereqs: an AUR account (https://aur.archlinux.org register, then add this
# machine's SSH public key at https://aur.archlinux.org/account), git, makepkg.
# To add aux files later, drop them in ./aur-aux/ before running.
set -euo pipefail

PKG=keep-awake-mode
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

cd "$HERE"

echo "==> generating .SRCINFO"
makepkg --printsrcinfo > .SRCINFO

echo "==> cloning AUR repo"
git clone "ssh://aur@aur.archlinux.org/$PKG.git" "$TMP/$PKG"

echo "==> staging PKGBUILD + .SRCINFO"
cp PKGBUILD .SRCINFO "$TMP/$PKG/"
if [ -d "$HERE/aur-aux" ]; then
    mkdir -p "$TMP/$PKG/aur-aux"
    cp -a "$HERE/aur-aux/." "$TMP/$PKG/aur-aux/"
fi

cd "$TMP/$PKG"
# AUR requires a minified PKGBUILD without comments (or all comments removed)
python3 - <<'EOF'
lines = open('PKGBUILD').read().split('\n')
out = []
for ln in lines:
    s = ln.strip()
    if s.startswith('#') or s == '':
        continue
    out.append(ln)
open('PKGBUILD', 'w').write('\n'.join(out) + '\n')
EOF

echo "==> verifying build of AUR PKGBUILD"
makepkg -f >/dev/null 2>&1 || { echo "!! AUR PKGBUILD build failed — not pushing"; exit 1; }
rm -f *.pkg.tar.zst src pkg 2>/dev/null || true
rm -rf src pkg

echo "==> committing + pushing"
git add -A
git -c user.name="Ekonop" -c user.email="vanshpratapsingh09@gmail.com" \
    commit -m "AUR submission: keep-awake-mode $PKG_VERSION" 2>/dev/null || true
git push

echo "==> done: https://aur.archlinux.org/packages/$PKG"