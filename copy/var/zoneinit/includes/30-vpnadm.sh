#!/usr/bin/env bash

# Generate Django SuperUser password
ADMIN_VPNADM=${ADMIN_VPNADM:-$(mdata-get vpnadm_admin 2>/dev/null)} || \
ADMIN_VPNADM=$(LC_ALL=C tr -cd '[:alnum:]' < /dev/urandom | head -c64);
mdata-put vpnadm_admin ${ADMIN_VPNADM}

# Configure settings.py
# _insertreplace FILE KEY VALUE
_insertreplace() {
	local file="${1}"; shift
	local key="${1}"; shift
	local value="${@}"
	if [[ "${value}" != "True"  && \
		  "${value}" != "False" && \
		  "${value:0:1}" != "[" ]]; then
		value="\"${value}\""
	fi
	if grep -q "${key}" ${file}; then
		gsed -i "s|^${key} \+=.*|${key} = ${value}|g" ${file}
	else
		echo "${key} = ${value}" >> ${file}
	fi
}

VPNADM_SETTINGS='/opt/vpnadm/vpnadm_web/settings.py'

_insertreplace ${VPNADM_SETTINGS} DEBUG False
_insertreplace ${VPNADM_SETTINGS} ALLOWED_HOSTS "[ '$(hostname)', '127.0.0.1', '::1' ]"
_insertreplace ${VPNADM_SETTINGS} OPENVPN_PATH /var/openvpn
_insertreplace ${VPNADM_SETTINGS} OPENVPN_MANAGEMENT_SOCKET /var/run/openvpn.sock
_insertreplace ${VPNADM_SETTINGS} OPENVPN_HOSTNAME $(hostname)
_insertreplace ${VPNADM_SETTINGS} DB_DIR /var/openvpn

# Init Django data and database (if it doesn't exists)
/opt/vpnadm/manage.py migrate --noinput --fake-initial

# Create SuperUser if it doesn't exists
cat <<EOF | /opt/vpnadm/manage.py shell
from django.contrib.auth import get_user_model
User = get_user_model()
User.objects.filter(username="admin").exists() or \
    User.objects.create_superuser("admin", "", "${ADMIN_VPNADM}")
EOF

# Enable gunicorn service
svcadm enable svc:/network/gunicorn:vpnadm
