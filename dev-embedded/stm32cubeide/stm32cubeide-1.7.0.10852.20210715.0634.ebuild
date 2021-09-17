# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit desktop udev

MY_PV=$(ver_rs 3- '_')
MY_P="st-stm32cubeide_${MY_PV}_amd64"

DESCRIPTION="Free all-in-one STM32 development tool"
HOMEPAGE="https://www.st.com/content/st_com/en/products/development-tools/software-development-tools/stm32-software-development-tools/stm32-ides/stm32cubeide.html"
SRC_URI="en.${MY_P}.sh_v$(ver_cut 1-3).zip"
RESTRICT="fetch strip" # binchecks

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"
IUSE="+stlink jlink openocd"

DEPEND="
	x11-libs/gtk+:2
	openocd? ( dev-embedded/openocd )
"
RDEPEND="${DEPEND}"
BDEPEND="
	app-arch/unzip
"

extract_sh()
{
	sh "$1" --nox11 --noprogress --noexec --target "${2:-.}"
}

pkg_nofetch()
{
	einfo "Please download"
	for dist in ${A[@]}; do
		einfo " - $dist"
	done
	einfo "from $HOMEPAGE"
	einfo "and place them into $DISTDIR"
}

src_unpack()
{
	unpack ${A}
	mkdir -p "$S" && \
		extract_sh "$WORKDIR/$MY_P.sh" "$T/$MY_P" && \
		mv "$T/$MY_P/$MY_P.tar.gz" "$S/$PN.tar.gz" \
		|| die "Failed to unpack"

	if use stlink; then
		extract_sh "$T/$MY_P"/st-stlink-udev-rules-*-linux-noarch.sh "$T/stlink" && \
			extract_sh "$T/$MY_P"/st-stlink-server.*-linux-amd64.install.sh "$T/stlink" && \
			mkdir -p "$S/stlink" && \
			mv "$T/stlink"/*.rules "$S/stlink" && \
			mv "$T/stlink/stlink-server" "$S/stlink" \
			|| die "Failed to unpack stlink"
	fi

	if use jlink; then
		extract_sh "$T/$MY_P"/segger-jlink-udev-rules-*-linux-noarch.sh "$T/jlink" && \
			mkdir -p "$S/jlink" && \
			mv "$T/jlink"/*.rules "$S/jlink" \
			|| die "Failed to unpack jlink"
	fi
}

src_install()
{
	local dest="$D/opt/$PN"
	mkdir -p "$dest" && \
		tar xf "$S/$PN.tar.gz" -C "$dest" \
		|| die "Failed to install"
	make_desktop_entry "/opt/$PN/$PN" "STM32CubeIDE" "/opt/$PN/icon.xpm"

	if use stlink; then
		dosbin "$S/stlink/stlink-server" && \
			udev_dorules "$S/stlink"/*.rules \
			|| die "Failed to install stlink"
		udev_reload
	fi

	if use jlink; then
		udev_dorules "$S/jlink"/*.rules \
			|| die "Failed to install jlink"
		udev_reload
	fi
}
