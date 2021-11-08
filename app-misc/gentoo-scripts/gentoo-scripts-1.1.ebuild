# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Some useful scripts for gentoo"
HOMEPAGE="https://github.com/DakEnviy/gentoo-scripts"
SRC_URI="https://github.com/DakEnviy/gentoo-scripts/archive/refs/tags/v${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+qtop +esync +eclt +eupd +rcms"

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
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_install() {
	if use qtop; then
		dobin qtop
	fi

	if use esync; then
		dobin esync
	fi

	if use eclt; then
		dobin eclt
	fi

	if use eupd; then
		dobin eupd
	fi

	if use rcms; then
		dobin rcms
	fi
}
