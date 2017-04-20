#!/bin/bash
## Set the proxy server environment on a cfpManagement resource
export http_proxy=http://forwardproxy.management.cfp:8080
export https_proxy=http://forwardproxy.management.cfp:8080
export HTTP_PROXY=http://forwardproxy.management.cfp:8080
export HTTPS_PROXY=http://forwardproxy.management.cfp:8080
export no_proxy="127.0.0.1, localhost, *.management.cfp"

