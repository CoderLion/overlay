# Distributed under the terms of the GNU General Public License v3
# Authors: Horea Christian, Robert Walker

EAPI=5

inherit eutils pax-utils user flag-o-matic multilib autotools pam systemd versionator

DESCRIPTION="Sync files & folders using BitTorrent protocol"
HOMEPAGE="http://labs.bittorrent.com/experiments/sync.html"
SRC_URI="amd64? ( https://download-cdn.getsync.com/stable/linux-x64/BitTorrent-Sync_x64.tar.gz )
	x86? ( https://download-cdn.getsync.com/stable/linux-i386/BitTorrent-Sync_i386.tar.gz )
	arm? ( https://download-cdn.getsync.com/stable/linux-arm/BitTorrent-Sync_arm.tar.gz )"

RESTRICT="mirror strip"
LICENSE="BitTorrent"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}"

QA_PREBUILT="/opt/${PN}/"

src_install() {
	dodoc "${S}/LICENSE.TXT"

	newconfd "${FILESDIR}/${PN}_confd" "/${PN}"
	
	# system-v-init support
	newinitd "${FILESDIR}/${PN}_initd" "/${PN}"
	
	# systemd support
	systemd_dounit "${FILESDIR}/${PN}.service"
	systemd_newunit "${FILESDIR}/${PN}_at.service" "${PN}@.service"
	#systemd_newuserunit "${FILESDIR}/${PN}_user.service" "${PN}.service"
	insinto "$(systemd_get_userunitdir)"
	newins "${FILESDIR}/${PN}_user.service" "${PN}.service"

	exeinto "/opt/${PN}/bin/"
	doexe "${FILESDIR}/${PN}_setup"
	doexe "${PN}"
}

pkg_preinst() {
	enewgroup "${PN}"
	enewuser "${PN}" -1 -1 -1 "${PN}"
	dodir "/run/${PN}"
	fowners "${PN}":"${PN}" "/run/${PN}"
	dodir "/var/lib/${PN}"
	fowners "${PN}":"${PN}" "/var/lib/${PN}"
}

pkg_postinst() {
einfo "Auto-generated configuration file is located at /etc/btsync.conf"
einfo "(use this file as a template for user-level privilege service units)"
einfo ""
einfo "systemd"
einfo "btsync.service:"
einfo " run as a system service as user/group btsync:btsync"
einfo " uses /var/lib/btsync for btsync working data"
einfo "btsync@<user>.service"
einfo " run as a system service but with user privilege"
einfo " uses /home/<user>/.btsync/btsync.conf for btsync working data"
einfo "btsync_user.service"
einfo " run as a standard user service"
einfo " uses /home/<user>/.btsync/btsync.conf for btsync working data"
einfo ""
einfo "Ensure you open the following ports in your firewall:"
einfo " btsync.conf specified sync listening port (UDP/TCP)"
einfo " port 3838 (UDP) for DHT tracking"
einfo ""
einfo "WebUI listens on: localhost:(8888), nominally localhost:(7888+UID)"

}
