# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A 15-band equalizer for PulseAudio"
HOMEPAGE="https://github.com/pulseaudio-equalizer-ladspa/equalizer"
SRC_URI="https://github.com/pulseaudio-equalizer-ladspa/equalizer/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	x11-libs/gtk+:3
	dev-python/pygobject:3
	media-sound/pulseaudio
	media-plugins/swh-plugins
	sys-devel/bc
"
RDEPEND="${DEPEND}"
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
