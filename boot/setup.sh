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

export PS4='[\D{%FT%TZ}] ${BASH_SOURCE}:${LINENO}: ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -o xtrace
set -o errexit

PATH=/opt/local/bin:/opt/local/sbin:/usr/bin:/usr/sbin

role=nfsserver

# Include common utility functions
source /opt/smartdc/boot/lib/util.sh

# We don't want all the boilerplate since we're not going to use config-agent
# and registrar, but we do want to rotate logs.
_sdc_create_dcinfo
_sdc_install_bashrc
_sdc_enable_cron
_sdc_log_rotation_setup

# Add build/node/bin and node_modules/.bin to PATH
echo "" >>/root/.profile
echo "export PATH=\$PATH:/opt/smartdc/nfsserver/build/node/bin:/opt/smartdc/nfsserver/node_modules/.bin" >>/root/.profile

echo "Adding log rotation"
# Log rotation.
sdc_log_rotation_add $role /var/svc/log/*$role*.log 1g
sdc_log_rotation_setup_end

# Setup /exports
mkdir -p /exports

# set mountpoint
UUID=$(zonename)
DATASET=zones/${UUID}/data

# This also mounts the dataset
zfs set mountpoint=/exports ${DATASET}

# All done, run boilerplate end-of-setup
sdc_setup_complete

exit 0

