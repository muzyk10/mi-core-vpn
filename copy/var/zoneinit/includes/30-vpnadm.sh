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
	if [[ "${value}" != "True" && "${value}" != "False" ]]; then
		value="\"${value}\""
	fi
	if grep -q "${key}" ${file}; then
		gsed -i "s/^${key} =.*/${key} = ${value}/g" ${file}
	else
		echo "${key} = ${value}" >> ${file}
	fi
}

VPNADM_SETTINGS='/opt/vpnadm/vpnadm_web/settings.py'
VPNADM_SQLITEDB='/var/openvpn/db.sqlite3'

_insertreplace ${VPNADM_SETTINGS} OPENVPN_PATH /var/openvpn
_insertreplace ${VPNADM_SETTINGS} OPENVPN_MANAGEMENT_SOCKET /var/run/openvpn.sock
_insertreplace ${VPNADM_SETTINGS} OPENVPN_HOSTNAME $(hostname)
# TODO: _insertreplace ${VPNADM_SETTINGS} SQLITEDB ${VPNADM_SQLITEDB}


# Verify if database already exists
if [[ ! -f ${VPNADM_SQLITEDB} ]]; then
	CREATE_SUPERUSER=1
fi

# Init Django data and database (if it doesn't exists)
/opt/vpnadm/manage.py migrate --noinput --fake-initial

# Create SuperUser
if [[ ${CREATE_SUPERUSER} == 1 ]]; then
	echo "from django.contrib.auth.models import User; User.objects.create_superuser('admin', '', '${ADMIN_VPNADM}')" | \
		/opt/vpnadm/manage.py shell
fi

# Enable gunicorn service
svcadm enable svc:/network/gunicorn:vpnadm
