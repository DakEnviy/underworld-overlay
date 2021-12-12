# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Java OpenJFX client application platform"
HOMEPAGE="https://gluonhq.com/products/javafx/"
SRC_URI="https://download2.gluonhq.com/openjfx/${PV}/openjfx-${PV}_linux-x64_bin-jmods.zip -> ${P}.zip"

LICENSE="GPL-2-with-classpath-exception"
SLOT="${PV%%[.+]*}"
KEYWORDS="~amd64"

DEPEND="
	dev-java/openjdk:${SLOT}
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-arch/unzip
"

S="${WORKDIR}/javafx-jmods-${PV}"

src_install() {
	insinto "/usr/$(get_libdir)/openjdk-${SLOT}/jmods"
	doins -r .
}
