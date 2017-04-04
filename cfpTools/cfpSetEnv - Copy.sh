#! /bin/bash

###
# cfpSetEnv.sh
#
# Functions for standard environment variables to be used in CFP scripts
# This is a collection of functions that get loaded at the top of other scripts
# APP_INST and SUB_APP are expected to be set by caller first using cfpSetApp function, if needed.
# If env is not needed for app execution, these can be left out and cfpSetEnv can be used directly
# So the root folder for all activities is in the variable DEFAULT_ROOT below; 
# A set of folders comes off of that for bin, data, logs.
# If an APP_INST is set, and additional sub-folder will be referenced in APP_DIR below the bin folder.
# If not set, APP_DIR will point to the root bin folder.
###

DEFAULT_ROOT='/usr/local'
# Functions:

cfpSetApp() {

#  set script name app instance and name from caller
export APP_INST=$1
export SUB_APP=$2
cfpSetEnv

}

cfpSetEnv() {

#  root app directory and sub-directories
DEFAULT_ROOT='/usr/local'
export ROOT_DIR=$DEFAULT_ROOT/$APP_INST
export DATA_DIR=$ROOT_DIR/data
export BIN_DIR=$ROOT_DIR/bin
export LOG_DIR=$ROOT_DIR/logs
export ARCHIVE_DIR=$DATA_DIR/archive
export LIB_DIR=$ROOT_DIR/lib

if [ -z "$SUB_APP" ] ;
  then 
  export SUB_ROOT_DIR=
  export SUB_DATA_DIR=
  export SUB_BIN_DIR=
  export SUB_LOG_DIR=
  export SUB_ARCHIVE_DIR=
  export SUB_LIB_DIR=
else
  export SUB_ROOT_DIR=$ROOT_DIR/$SUB_APP
  export SUB_DATA_DIR=$SUB_ROOT_DIR/data
  export SUB_BIN_DIR=$SUB_ROOT_DIR/bin
  export SUB_LOG_DIR=$SUB_ROOT_DIR/logs
  export SUB_ARCHIVE_DIR=$SUB_ROOT_DIR/archive
  export SUB_LIB_DIR=$SUB_ROOT_DIR/lib
fi

# TODO: figure out how to log using called script name instead of top script name
# called=$_
# [[ $called != $0 ]] && echo "Script is being sourced" || echo "Script is being run"
# echo "\$BASH_SOURCE ${BASH_SOURCE[@]}"
# echo "0 is $0  dollar_ is $_ "

export SCRIPT_NAME="$( basename $0 )"
# Timestamp format for filenames
export TIMESTAMP=`date +%Y%m%d-%H%M%S`

cfpShowEnv

}

#  display the variables
cfpShowEnv() {

WriteLog "Show CFP Environment Variables: "
WriteLog "SCRIPT_NAME= $SCRIPT_NAME "
WriteLog "APP_INST= $APP_INST "
WriteLog "ROOT_DIR= $ROOT_DIR "
WriteLog "DATA_DIR= $DATA_DIR "
WriteLog "BIN_DIR= $BIN_DIR "
WriteLog "LOG_DIR= $LOG_DIR "
WriteLog "ARCHIVE_DIR= $ARCHIVE_DIR "
WriteLog "APP_DIR= $APP_DIR "
WriteLog "LIB_DIR= $LIB_DIR "

if [ -z "$SUB_APP" ] ;
  then 
  WriteLog "SUB_APP= none "
else
  WriteLog "SUB_APP= $SUB_APP "
  WriteLog "SUB_ROOT_DIR= $SUB_ROOT_DIR "
  WriteLog "SUB_DATA_DIR= $SUB_DATA_DIR "
  WriteLog "SUB_BIN_DIR= $SUB_BIN_DIR "
  WriteLog "SUB_LOG_DIR= $SUB_LOG_DIR "
  WriteLog "SUB_ARCHIVE_DIR= $SUB_ARCHIVE_DIR "
  WriteLog "SUB_APP_DIR= $SUB_APP_DIR "
  WriteLog "SUB_LIB_DIR= $SUB_LIB_DIR "
fi

WriteLog "TIMESTAMP= $TIMESTAMP "

}

#  log writer
WriteLog() {
export TIMESTAMP=`date +%Y%m%d-%H%M%S`
echo $TIMESTAMP $SCRIPT_NAME $1
}

#  debug log writer
WriteDebugLog() {
if [ $DEBUG_ON -eq $TRUE ]; then
	WriteLog "$1"
fi
}

#  log start of process
LogStart() {
WriteLog "Start Parms=$1"
}

#  log stop of process
LogStop() {
WriteLog "Stop"
}

#  if run stand-alone parms will be present, will call functions in order:
# Parms APP_INST APP_NAME
echo $# $1 $2 $3
if [ $# -gt 0 ]; then
	cfpSetApp $1 $2
	LogStart
	cfpShowEnv
	LogStop
	exit 0
fi

