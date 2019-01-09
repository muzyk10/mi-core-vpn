#!/usr/bin/env bash
# Generate OpenVPN configuration file and start service

VPNADM_PATH='/opt/vpnadm'
${VPNADM_PATH}/manage.py generate_server_config > \
	/opt/local/etc/openvpn/openvpn.conf

svcadm enable svc:/pkgsrc/openvpn:default
