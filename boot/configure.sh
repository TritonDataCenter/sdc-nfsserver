#!/usr/bin/bash
# -*- mode: shell-script; fill-column: 80; -*-
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2016, Joyent, Inc.
#

export PS4='+[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }--'
set -o xtrace

echo "Updating SMF manifest"
$(/opt/local/bin/gsed -i"" -e "s/@@PREFIX@@/\/opt\/smartdc\/nfsserver/g" /opt/smartdc/nfsserver/smf/nfsserver.xml)

echo "Creating Volume Directories"
volumes=0
for volume in $(mdata-get export-volumes | json -a | grep "^[a-zA-Z0-9\-\_]*$"); do
    volumes=$((${volumes} + 1))
    mkdir -p /exports/${volume}
done

if [[ ${volumes} -lt 1 ]]; then
    echo "FATAL: no volumes to export! (customer_metadata.export-volumes)" >&2
    exit 2
fi

echo "Importing rpc/bind.xml"
svccfg import /lib/svc/manifest/network/rpc/bind.xml

echo "Enabling remote mounting"
svccfg -s bind setprop config/local_only=false
svcadm refresh bind

echo "Importing nfsserver.xml"
/usr/sbin/svccfg import /opt/smartdc/nfsserver/smf/nfsserver.xml

exit 0

