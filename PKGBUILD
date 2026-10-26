# Maintainer: Vansh Pratap Singh <vanshpratapsingh09@gmail.com>
pkgname=keep-awake-mode
pkgver=1.0.2
pkgrel=1
pkgdesc="Performance Keep-Awake mode for KDE Plasma 6: performance profile + block sleep (display may still turn off), plus a battery applet fork with a Keep-Awake slider stop"
arch=('any')
url="https://github.com/Ekonop/keep-awake-mode"
license=('MIT' 'LGPL-2.0-or-later')
depends=('bash' 'systemd' 'power-profiles-daemon' 'plasma-workspace' 'qt6-declarative' 'python')
source=("$pkgname-$pkgver::git+https://github.com/Ekonop/keep-awake-mode.git#tag=v$pkgver")
sha256sums=('SKIP')

package() {
    local src="$srcdir/$pkgname-$pkgver"

    # script
    install -Dm755 "$src/keep-awake-mode" \
        "$pkgdir/usr/bin/keep-awake-mode"

    # launcher
    install -Dm644 "$src/applications/keep-awake-mode.desktop" \
        "$pkgdir/usr/share/applications/keep-awake-mode.desktop"

    # plasmoid
    local pid="vansh.keepawake.battery"
    install -Dm644 "$src/plasmoid/$pid/metadata.json" \
        "$pkgdir/usr/share/plasma/plasmoids/$pid/metadata.json"
    install -Dm644 "$src/plasmoid/$pid/contents/config/main.xml" \
        "$pkgdir/usr/share/plasma/plasmoids/$pid/contents/config/main.xml"
    install -Dm644 -t "$pkgdir/usr/share/plasma/plasmoids/$pid/contents/ui/" \
        "$src/plasmoid/$pid"/contents/ui/*.qml
}