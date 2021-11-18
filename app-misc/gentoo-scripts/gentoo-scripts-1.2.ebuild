# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Some useful scripts for gentoo"
HOMEPAGE="https://github.com/DakEnviy/gentoo-scripts"
SRC_URI="https://github.com/DakEnviy/gentoo-scripts/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+qtop +esync +eclt +eupd +rcms auto-sudo"

DEPEND="
	qtop? (
		app-portage/portage-utils
	)
	esync? (
		sys-apps/portage
	)
	eclt? (
		sys-apps/portage
		app-portage/portage-utils
	)
	eupd? (
		sys-apps/portage
	)
	rcms? (
		sys-apps/openrc
	)
	auto-sudo? (
		app-admin/sudo
	)
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	if use auto-sudo; then
		eapply "${FILESDIR}/enable-auto-sudo.patch"
	fi

	eapply_user
}

src_install() {
	if use qtop; then
		dobin scripts/qtop
	fi

	if use esync; then
		dobin scripts/esync
	fi

	if use eclt; then
		dobin scripts/eclt
	fi

	if use eupd; then
		dobin scripts/eupd
	fi

	if use rcms; then
		dobin scripts/rcms
	fi
}
