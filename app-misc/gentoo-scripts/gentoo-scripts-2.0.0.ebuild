# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9,10,11} )

inherit python-single-r1

DESCRIPTION="Some useful scripts for gentoo"
HOMEPAGE="https://github.com/DakEnviy/gentoo-scripts"
SRC_URI="https://github.com/DakEnviy/gentoo-scripts/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+qtop +esync +eclt +eupd +rcms +enewyear +qorph auto-sudo"
REQUIRED_USE="qorph? ( ${PYTHON_REQUIRED_USE} )"

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
	enewyear? (
		sys-apps/portage
	)
	qorph? (
		${PYTHON_DEPS}
		app-portage/gentoolkit
	)
	auto-sudo? (
		app-admin/sudo
	)
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_prepare() {
	if use auto-sudo; then
		sed -i "s/AUTO_SUDO=0/AUTO_SUDO=1/g" scripts/*
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

	if use enewyear; then
		dobin scripts/enewyear
	fi

	if use qorph; then
		dobin scripts/qorph
	fi

	insinto "/etc/${PN}"
	newins "${FILESDIR}/.qorphignore" ".qorphignore"
}
