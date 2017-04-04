#! /bin/bash

#TODO add more test cases

# Begin cfpSampleScript.sh
# This script demonstrates and tests the cfp scripting environment
	DEBUG_ON=$TRUE

# cd /usr/local/ets/bin  #hard-coded for now...
# Set up the environment assuming the cfp core environment and an app called SampleTest
source cfpSetEnv.sh  cfpCore SampleTest  # load environment functions and set app

LogStart "$*"

LogDebug "this is only a debugging log item"

LogEnd

# End cfpSampleScript.sh
EOF
