# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{3_8,3_9} )

inherit meson python-r1

DESCRIPTION="A 15-band equalizer for PulseAudio"
HOMEPAGE="https://github.com/pulseaudio-equalizer-ladspa/equalizer"
SRC_URI="https://github.com/pulseaudio-equalizer-ladspa/equalizer/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	${PYTHON_DEPS}
	>=dev-python/pygobject-3.30[${PYTHON_USEDEP}]
	x11-libs/gtk+:3
	media-sound/pulseaudio
	media-plugins/swh-plugins
	sys-devel/bc
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/ninja
	>=dev-util/meson-0.46
"

S="${WORKDIR}/equalizer-${PV}"

src_compile() {
	meson_src_compile
}

src_install() {
	meson_src_install
}
