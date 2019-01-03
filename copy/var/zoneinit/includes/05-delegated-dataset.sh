#!/bin/bash
UUID=$(mdata-get sdc:uuid)
DDS=zones/${UUID}/data

if zfs list ${DDS} 1>/dev/null 2>&1; then
	zfs create ${DDS}/openvpn  || true

	if ! zfs get -o value -H mountpoint ${DDS}/openvpn | grep -q /var/openvpn; then
		zfs set mountpoint=/var/openvpn ${DDS}/openvpn
	fi
fi
