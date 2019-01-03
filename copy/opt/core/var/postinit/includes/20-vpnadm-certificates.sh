#!/usr/bin/env bash
# Generate CA, DH, ServerCert, TA for OpenVPN Server

VPNADM_PATH='/opt/vpnadm'
OPENVPN_PATH=$(sed -n "s/OPENVPN_PATH.*=.*'\(.*\)'.*/\1/p" ${VPNADM_PATH}/vpnadm_web/settings.py)

# Check if file exists and run generation command if required
[ ! -f ${OPENVPN_PATH}/certs/ca.crt ] && \
	${VPNADM_PATH}/manage.py generate_ca \
	${OPENVPN_PATH}/certs/ca.crt
[ ! -f ${OPENVPN_PATH}/certs/dh.pem ] && \
	${VPNADM_PATH}/manage.py generate_dh \
	${OPENVPN_PATH}/certs/dh.pem
[ ! -f ${OPENVPN_PATH}/certs/srv.key ] && \
	${VPNADM_PATH}/manage.py generate_server_cert \
	${OPENVPN_PATH}/certs/srv.key ${OPENVPN_PATH}/certs/srv.crt
[ ! -f ${OPENVPN_PATH}/certs/tls_auth.key ] && \
	${VPNADM_PATH}/manage.py generate_ta \
	${OPENVPN_PATH}/certs/tls_auth.key
