#!/bin/bash
## Set the proxy server environment on a cfpManagement resource
export http_proxy=http://forwardproxy.management.cfp:8080
export https_proxy=http://forwardproxy.management.cfp:8080
export HTTP_PROXY=http://forwardproxy.management.cfp:8080
export HTTPS_PROXY=http://forwardproxy.management.cfp:8080
export no_proxy="127.0.0.1, localhost, *.management.cfp, 169.254.169.254"

# # curl and wget honor the env vars, so this would be activated only if problems or different needs
# cat << EOF > $HOME/.wgetrc
# use_proxy=yes
# http_proxy=$http_proxy
# https_proxy=$https_proxy
# HTTP_PROXY=$HTTP_PROXY
# HTTPS_PROXY=$HTTPS_PROXY
# no_proxy = $no_proxy
# EOF

# cat << EOF > $HOME/.curlrc
# proxy=$http_proxy
# no_proxy = $no_proxy
# EOF

# # figure out how to get user out of home dir
# sudo -E chown $ADMIN_GROUP $HOME_DIR/.curlrc
# sudo -E chgrp $ADMIN_GROUP $HOME_DIR/.curlrc
# sudo -E chown $ADMIN_GROUP $HOME_DIR/.wgetrc
# sudo -E chgrp $ADMIN_GROUP $HOME_DIR/.wgetrc
