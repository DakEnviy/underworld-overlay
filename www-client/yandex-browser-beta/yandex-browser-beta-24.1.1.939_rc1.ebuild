# Copyright 2021-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# This must be placed before 'inherit chromium-2'
CHROMIUM_LANGS="cs de en-US es fr it ja pt-BR pt-PT ru tr uk zh-CN zh-TW"

inherit chromium-2 unpacker pax-utils xdg-utils

RESTRICT="bindist mirror strip"

MY_PV="${PV/_rc/-}"

DESCRIPTION="The web browser from Yandex"
HOMEPAGE="https://browser.yandex.ru/beta/"
LICENSE="Yandex-EULA"
SLOT="0"
SRC_URI="
	amd64? ( https://repo.yandex.ru/yandex-browser/deb/pool/main/y/yandex-browser-beta/yandex-browser-beta_${MY_PV}_amd64.deb -> ${P}.deb )
"
KEYWORDS="~amd64 ~x86"
IUSE="+ffmpeg-codecs"

# RDEPEND="
# 	sys-devel/binutils				# binutils
# 	media-fonts/liberation-fonts	# fonts-liberation
# 	>=media-libs/alsa-lib-1.0.17	# libasound2
# 	>=app-accessibility/at-spi2-core-2.9.90 # libatk-bridge2.0-0
# 									# libatk1.0-0
# 									# libatspi2.0-0
# 	virtual/libc					# libc6
# 	>=x11-libs/cairo-1.6.0			# libcairo2
# 	>=net-print/cups-1.6.0			# libcups2
# 	net-misc/curl					# libcurl3-gnutls | libcurl3-nss | libcurl4 | libcurl3
# 	>=sys-apps/dbus-1.9.14			# libdbus-1-3
# 	>=x11-libs/libdrm-2.4.75		# libdrm2
# 	>=dev-libs/expat-2.0.1			# libexpat1
# 	>=media-libs/mesa-17.1.0		# libgbm1
# 	>=dev-libs/glib-2.39.4:2		# libglib2.0-0
# 	x11-libs/gtk+:2					# libgtk-3-0 (>= 3.9.10) | libgtk-4-1
# 	>=dev-libs/nspr-4.9				# libnspr4
# 	>=dev-libs/nss-3.35				# libnss3
# 	>=x11-libs/pango-1.14.0 [X]		# libpango-1.0-0
# 	media-libs/vulkan-loader		# libvulkan1
# 	>=x11-libs/libX11-1.4.99.1		# libx11-6
# 	>=x11-libs/libxcb-1.9.2			# libxcb1
# 	>=x11-libs/libXcomposite-0.4.4	# libxcomposite1
# 	>=x11-libs/libXdamage-1.1		# libxdamage1
# 	x11-libs/libXext				# libxext6
# 	x11-libs/libXfixes				# libxfixes3
# 	>=x11-libs/libxkbcommon-0.5.0	# libxkbcommon0
# 	x11-libs/libxkbfile				# libxkbfile1
# 	x11-libs/libXrandr				# libxrandr2
# 	>=x11-misc/xdg-utils-1.0.2		# xdg-utils
# 	>=dev-libs/openssl-1.0.1:0
# 	media-libs/fontconfig
# 	media-libs/freetype
# 	sys-libs/libcap
# 	virtual/libudev
# 	x11-libs/gdk-pixbuf
# 	x11-libs/libXScrnSaver
# 	x11-libs/libXcursor
# 	x11-libs/libXi
# 	x11-libs/libXrender
# 	x11-libs/libXtst
# 	sys-libs/libudev-compat
# 	ffmpeg-codecs? (
# 		app-misc/jq					# jq
# 		net-misc/wget				# wget
# 		sys-fs/squashfs-tools		# squashfs-tools
# 	)
# "

RDEPEND="
	sys-devel/binutils
	media-fonts/liberation-fonts
	>=media-libs/alsa-lib-1.0.17
	>=app-accessibility/at-spi2-core-2.9.90
	virtual/libc
	>=x11-libs/cairo-1.6.0
	>=net-print/cups-1.6.0
	net-misc/curl
	>=sys-apps/dbus-1.9.14
	>=x11-libs/libdrm-2.4.75
	>=dev-libs/expat-2.0.1
	>=media-libs/mesa-17.1.0
	>=dev-libs/glib-2.39.4:2
	x11-libs/gtk+:2
	>=dev-libs/nspr-4.9
	>=dev-libs/nss-3.35
	>=x11-libs/pango-1.14.0[X]
	media-libs/vulkan-loader
	>=x11-libs/libX11-1.4.99.1
	>=x11-libs/libxcb-1.9.2
	>=x11-libs/libXcomposite-0.4.4
	>=x11-libs/libXdamage-1.1
	x11-libs/libXext
	x11-libs/libXfixes
	>=x11-libs/libxkbcommon-0.5.0
	x11-libs/libxkbfile
	x11-libs/libXrandr
	>=x11-misc/xdg-utils-1.0.2
	>=dev-libs/openssl-1.0.1:0
	media-libs/fontconfig
	media-libs/freetype
	sys-libs/libcap
	virtual/libudev
	x11-libs/gdk-pixbuf
	x11-libs/libXScrnSaver
	x11-libs/libXcursor
	x11-libs/libXi
	x11-libs/libXrender
	x11-libs/libXtst
	sys-libs/libudev-compat
	ffmpeg-codecs? (
		app-misc/jq
		net-misc/wget
		sys-fs/squashfs-tools
	)
"

DEPEND="
	>=dev-util/patchelf-0.9
"

QA_PREBUILT="*"
S=${WORKDIR}
YANDEX_HOME="opt/${PN/-//}"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack_deb ${A}
}

src_prepare() {
	# this was here for a long time (from the first version of the ebuild),
	# but now this prevents installing a symlink of the yandex-browser in /usr/bin
	# and breaks .desktop files
	#
	# rm usr/bin/${PN} || die

	rm -r etc || die

	rm -r "${YANDEX_HOME}/cron" || die

	gunzip usr/share/doc/${PN}/changelog.gz || die
	gunzip usr/share/man/man1/${PN}.1.gz || die

	mv usr/share/doc/${PN} usr/share/doc/${PF} || die

	pushd "${YANDEX_HOME}/locales" > /dev/null || die
	chromium_remove_language_paks
	popd > /dev/null || die

	default

	sed -r \
		-e 's|\[(NewWindow)|\[X-\1|g' \
		-e 's|\[(NewIncognito)|\[X-\1|g' \
		-e 's|^TargetEnvironment|X-&|g' \
		-i usr/share/applications/${PN}.desktop || die

	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser-sandbox" || die "Failed to fix library rpath (yandex_browser-sandbox)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/yandex_browser" || die "Failed to fix library rpath (yandex_browser)"
	patchelf --remove-rpath "${S}/${YANDEX_HOME}/find_ffmpeg" || die "Failed to fix library rpath (find_ffmpeg)"

	# Removed in 23.9.1.837-1
	# patchelf --remove-rpath "${S}/${YANDEX_HOME}/nacl_helper" || die "Failed to fix library rpath (nacl_helper)"
}

src_install() {
	mv * "${D}" || die
	dodir "/usr/$(get_libdir)/${PN}/lib"
	make_wrapper "${PN}" "./${PN}" "${EPREFIX}/${YANDEX_HOME}" "${EPREFIX}/usr/$(get_libdir)/${PN}/lib"

	# yandex_browser binary loads libudev.so.0 at runtime
	dosym "${EPREFIX}/usr/$(get_libdir)/libudev.so.0" "${EPREFIX}/usr/$(get_libdir)/${PN}/lib/libudev.so.0"

	keepdir "${EPREFIX}/${YANDEX_HOME}"
	for icon in "${D}/${YANDEX_HOME}/product_logo_"*.png; do
		size="${icon##*/product_logo_}"
		size=${size%.png}
		dodir "/usr/share/icons/hicolor/${size}x${size}/apps"
		newicon -s "${size}" "$icon" "yandex-browser-beta.png"
	done

	fowners root:root "${EPREFIX}/${YANDEX_HOME}/yandex_browser-sandbox"
	fperms 4711 "${EPREFIX}/${YANDEX_HOME}/yandex_browser-sandbox"
	pax-mark m "${ED}${YANDEX_HOME}/yandex_browser-sandbox"
}

pkg_postinst() {
	xdg_desktop_database_update
	if use ffmpeg-codecs; then
		# Not working now
		# bash "/${YANDEX_HOME}/update-ffmpeg"

		"/${YANDEX_HOME}/update_codecs" "/${YANDEX_HOME}"
	else
		ewarn "For a complete support for video and audio in the HTML5 format"
		ewarn "see: https://yandex.ru/support/browser-beta/working-with-files/video.html#problems__video-linux"
	fi
}

pkg_postrm() {
	xdg_desktop_database_update
}
