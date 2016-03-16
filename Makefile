#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#

#
# Copyright (c) 2016, Joyent, Inc.
#

#
# Makefile.defs defines variables used as part of the build process.
#
include ./tools/mk/Makefile.defs

#
# Historically, Node packages that make use of binary add-ons must ship their
# own Node built with the same compiler, compiler options, and Node version that
# the add-on was built with.  On SmartOS systems, we use prebuilt Node images
# via Makefile.node_prebuilt.defs.  On other systems, we build our own Node
# binary as part of the build process.  Other options are possible -- it depends
# on the need of your repository.
#
NODE_PREBUILT_VERSION=v4.4.0
ifeq ($(shell uname -s),SunOS)
	# Allow building on a SmartOS image other than sdc-*-multiarch 15.4.1.
	NODE_PREBUILT_IMAGE=18b094b0-eb01-11e5-80c1-175dac7ddf02
	NODE_PREBUILT_TAG=zone
	include ./tools/mk/Makefile.node_prebuilt.defs
else
	include ./tools/mk/Makefile.node.defs
endif

#
# Repo-specific targets
#
.PHONY: all
all: | $(NPM_EXEC) sdc-scripts
	$(NPM) install

#
# Target definitions.  This is where we include the target Makefiles for
# the "defs" Makefiles we included above.
#

include ./tools/mk/Makefile.deps

ifeq ($(shell uname -s),SunOS)
	include ./tools/mk/Makefile.node_prebuilt.targ
else
	include ./tools/mk/Makefile.node.targ
endif

include ./tools/mk/Makefile.targ

sdc-scripts: deps/sdc-scripts/.git
