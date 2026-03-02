# Copyright 2021-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Derived from github.com/yandex-gentoo/overlay

EAPI=8
CHROMIUM_LANGS="cs de en-US es fr it ja kk pt-BR pt-PT ru tr uk uz zh-CN zh-TW"
inherit chromium-2 unpacker desktop wrapper pax-utils xdg

MY_PV="${PV/_rc/-}"
FFMPEG_PV="142"

DESCRIPTION="The web browser from Yandex"
HOMEPAGE="https://browser.yandex.ru/beta/"
LICENSE="Yandex-EULA"

SRC_URI="
	amd64? ( https://repo.yandex.ru/yandex-browser/deb/pool/main/y/${PN}/${PN}_${MY_PV}_amd64.deb -> ${P}.deb )
"

SLOT="0"
KEYWORDS="~amd64"
IUSE="+ffmpeg-codecs qt5 qt6"
RESTRICT="bindist mirror strip"

BDEPEND="
	>=dev-util/patchelf-0.9
"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	>=dev-libs/openssl-1.0.1:0
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	net-misc/curl
	net-print/cups
	sys-apps/dbus
	sys-libs/libcap
	virtual/libudev
	x11-libs/cairo
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/pango[X]
	x11-misc/xdg-utils
	ffmpeg-codecs? ( media-video/ffmpeg-chromium:${FFMPEG_PV} )
	sys-libs/libudev-compat
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtgui:5[X]
		dev-qt/qtwidgets:5
	)
	qt6? (
		dev-qt/qtbase:6[gui,widgets]
	)
	app-accessibility/at-spi2-core
"

S=${WORKDIR}
YANDEX_HOME="opt/${PN/-//}"

QA_PREBUILT="*"
QA_DESKTOP_FILE="usr/share/applications/yandex-browser.*\\.desktop"

pkg_pretend() {
	# Protect against people using autounmask overzealously
	use amd64 || die "${PN} only works on amd64"
}

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	rm "usr/bin/${PN}" || die "Failed to remove bundled wrapper"

	rm -r etc || die "Failed to remove etc"

	rm -r "${YANDEX_HOME}/cron" || die "Failed ro remove cron hook"

	mv usr/share/doc/${PN} usr/share/doc/${PF} || die "Failed to move docdir"

	gunzip \
		"usr/share/doc/${PF}/changelog.gz" \
		"usr/share/man/man1/${PN}.1.gz" \
	|| die "Failed to decompress docs"

	pushd "${YANDEX_HOME}/locales" > /dev/null || die "Failed to cd into locales dir"
		chromium_remove_language_paks
	popd > /dev/null || die

	if ! use qt5; then
		rm "${YANDEX_HOME}/libqt5_shim.so" || die
	fi
	if ! use qt6; then
		rm "${YANDEX_HOME}/libqt6_shim.so" || die
	fi

	grep '\<142\.[0-9]\+\.[0-9]\+\>' "${YANDEX_HOME}/update-ffmpeg" >/dev/null \
		|| ewarn "Wrong ffmpeg version in ebuild!"

	local crap=(
		"${YANDEX_HOME}/xdg-settings"
		"${YANDEX_HOME}/xdg-mime"
		"${YANDEX_HOME}/update-ffmpeg"
		"${YANDEX_HOME}/update_codecs"
		"${YANDEX_HOME}/compiz.sh"
	)

	test -L "usr/share/man/man1/yandex-browser.1.gz" &&
		crap+=("usr/share/man/man1/yandex-browser.1.gz")

	rm ${crap[@]} || die "Failed to remove bundled crap"

	default

	sed -r \
		-e 's|\[(NewWindow)|\[X-\1|g' \
		-e 's|\[(NewIncognito)|\[X-\1|g' \
		-e 's|^TargetEnvironment|X-&|g' \
		-i usr/share/applications/${PN}.desktop || die

	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser-sandbox" || die "Failed to fix library rpath (sandbox)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser" || die "Failed to fix library rpath (yandex_browser)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/find_ffmpeg" || die "Failed to fix library rpath (find_ffmpeg)"
}

src_install() {
	mv * "${D}" || die
	dodir "/usr/$(get_libdir)/${PN}/lib"
	mv "${D}/usr/share/appdata" "${D}/usr/share/metainfo" || die

	make_wrapper "${PN}" "./${PN}" "/${YANDEX_HOME}" "/usr/$(get_libdir)/${PN}/lib" \
		|| die "Failed to make a wrapper"

	for icon in "${D}/${YANDEX_HOME}/product_logo_"*.png; do
		size="${icon##*/product_logo_}"
		size=${size%.png}
		dodir "/usr/share/icons/hicolor/${size}x${size}/apps"
		newicon -s "${size}" "$icon" "${PN}.png"
	done

	dosym ../../../usr/"$(get_libdir)"/chromium/libffmpeg.so."${FFMPEG_PV}" "${YANDEX_HOME}"/libffmpeg.so || die

	fowners root:root "/${YANDEX_HOME}/yandex_browser-sandbox"
	fperms 4711 "/${YANDEX_HOME}/yandex_browser-sandbox"
	pax-mark m "${ED}${YANDEX_HOME}/yandex_browser-sandbox"
}
