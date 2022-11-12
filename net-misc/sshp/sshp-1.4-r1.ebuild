# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A wrapper for ssh for simple access via password"
HOMEPAGE="https://github.com/DakEnviy/sshp"
SRC_URI="https://github.com/DakEnviy/sshp/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	sys-apps/coreutils
	sys-apps/util-linux
	net-misc/openssh
	net-misc/sshpass
	dev-libs/openssl
	x11-misc/xclip
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	dobin sshp
}
