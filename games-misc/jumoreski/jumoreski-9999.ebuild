# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="d68ca1dd189f6ca933c2ac2d0bc5a01295ca1185"

DESCRIPTION="Bring colorful and funny Jumoreski into your workspace!"
HOMEPAGE="https://github.com/BobIsOnFire/jumoreski"
SRC_URI="https://github.com/BobIsOnFire/jumoreski/archive/${COMMIT}.zip -> ${PF}.zip"

LICENSE="|| ( Artistic GPL-1+ )"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
REQUIRED_USE=""

DEPEND="
	>=dev-lang/perl-5
	games-misc/fortune-mod
	games-misc/lolcat
"
RDEPEND="${DEPEND}"
BDEPEND="${DEPEND} app-arch/unzip"

PATCHES=(
	"${FILESDIR}/destdir.patch"
)

src_install() {
	insinto "/usr/share"
	doins -r jumoreski

	./cowsay/install.sh "${D}/usr/share/jumoreski" || die "Cowsay installer failed"

	insinto "/etc/profile.d"
	doins jumoreski.sh
}
