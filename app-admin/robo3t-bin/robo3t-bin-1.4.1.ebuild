# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop

_BASENAME="robo3t"
_EDITION="linux-x86_64"
_HASH="122dbd9"
_FILENAME="${_BASENAME}-${PV}-${_EDITION}-${_HASH}"

DESCRIPTION="Shell-centric MongoDB management tool"
HOMEPAGE="https://robomongo.org/"
SRC_URI="
	https://download.studio3t.com/robomongo/linux/${_FILENAME}.tar.gz -> ${P}.tar.gz
	https://raw.githubusercontent.com/Studio3T/robomongo/master/src/robomongo/gui/resources/icons/logo-256x256.png
"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	dev-qt/qtcore:5
	dev-libs/openssl
	net-misc/curl
"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${_BASENAME}"

src_unpack() {
	unpack ${P}.tar.gz
}
