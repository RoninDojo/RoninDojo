# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: BTCxZelko <btcxzelko@protonmail.com>
pkgname=roninbackend
pkgver=v1.5
pkgrel=1
epoch=
pkgdesc="RoninDojo: a Samourai Wallet node launcher on SBC"
arch=( aarch64 )
url="https://code.samourai.io/ronindojo/ronindojo"
license=('AGPL')
groups=()
depends=("python3" "docker" "docker-compose" "vim" "jdk11-openjdk" "tor" "ufw" "fail2ban" "htop" "unzip" "net-tools" "which" "wget" "nodejs-lts-erbium" "git" "jq")
makedepends=()
checkdepends=()
optdepends=()
provides=()
conflicts=()
replaces=()
backup=()
options=()
install=$pkgname.install
changelog=
source=("https://code.samourai.io/ronindojo/RoninDojo/-/archive/$pkgver/$pkgname.tar.gz")
noextract=()
md5sums=()
validpgpkeys=("7805F9879A5D4034F2B2D2F99818F379C1E4B25F"
"C67419AE12E2C6D455D68C88A41929893E692B32"
)

prepare() {
	cd "$pkgname-$pkgver"
	tar xvf $pkgname-$pkgver
}

#build() {
#	cd "$pkgname-$pkgver"
#	./configure --prefix=/usr
#	make
#}

check() {
	cd "$pkgname-$pkgver"
	gpg --search-keys 7805F9879A5D4034F2B2D2F99818F379C1E4B25F
	gpg --verify $pkgname-$pkgver.sig
}

package() {
	cd "$pkgname-$pkgver"
	DESTDIR="$HOME" install
}
