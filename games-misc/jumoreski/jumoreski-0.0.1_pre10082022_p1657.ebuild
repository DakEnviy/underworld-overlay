# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

COMMIT="4ddd89109784e324dfec96e3f28dabc5078eedc2"

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
	sys-apps/coreutils
"
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-lang/perl-5
	sys-apps/coreutils
	app-arch/unzip
"
IDEPEND="games-misc/fortune-mod"

S="${WORKDIR}/${PN}-${COMMIT}"

PATCHES=(
	"${FILESDIR}/destdir.patch"
)

src_install() {
	mv fortune jumoreski

	insinto "/usr/share"
	doins -r jumoreski

	./cowsay/install.sh "${D}/usr/share/jumoreski/cowsay" || die "Cowsay installer failed"

	insinto "/etc/profile.d"
	doins jumoreski.sh
}

pkg_postinst() {
	strfile "/usr/share/jumoreski/jumoreski"

	einfo "File jumoreski.sh installed into /etc/profile.d contains functions print_motd and"
	einfo "print_jumoreski. If your shell don't source /etc/profile.d (e.g. zsh), source this"
	einfo "file manually in your rc file (e.g. .zshrc)."

	einfo "It is recommend to add print_jumoreski function call into your rc file :)"
}

pkg_prerm() {
	rm "/usr/share/jumoreski/jumoreski.dat"
}
