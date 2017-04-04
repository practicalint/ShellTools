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

# DEFAULT_ROOT='/usr/local'
# Functions:

###
# cfpCreateEnv sub-module
#
#   (a subset of the setenv.sh is the creation of the environment when needed)
# Test for and create if necessary the components of the CFP environment.
# This would normally be called at the creation of a new instance,
# but due to it's idempotent nature could be called at any time to ensure the current version of the environment exists.
###

## declare array of dirs needed
#   (you can access them using echo "${arr[0]}", "${arr[1]}" also)
declare -a dirList=("bin" 
                	"data"
                	"logs"
                	"lib"
                	"archive"
                	"etc"
                	)


#
# Functions:
#
cfpCheckCreateDirs() {
# Create the parent directory if it does not exist
# This can be called for the top instance directory or a lower App directory structure.
# The content of ROOT_DIR drives the creation

if [ ! -e $ROOT_DIR ] 
	then
		echo "=== Root directory $ROOT_DIR not found, creating it ==="
		mkdir "$ROOT_DIR" 
fi

## declare array of dirs needed
#   (you can access them using echo "${arr[0]}", "${arr[1]}" also)
# declare -a dirList=("bin" 
                	# "data"
                	# "logs"
                	# "lib"
                	# "archive"
                	# "etc"
                	# )

## now loop through the array and create as needed
for dirName in "${dirList[@]}"
do
	dirNameFull=$ROOT_DIR/$dirName
	if [ ! -e $dirNameFull ]
		then
		echo "=== $dirName directory not found, creating it ==="
		mkdir $dirNameFull
	else
		echo "=== $dirName directory exists ==="
	fi
done

}

cfpCheckCreateGroup() {
# Check for group existing and add if not
egrep -i "^$1" /etc/group;
if [ $? -eq 0 ]; then
   echo "$1 Group Exists"
else
   echo "Group $1 does not exist "
   groupadd $1
fi

}


cfpParseArgs() {

# parse parms args in a standard linux command format with short and long into variables.
# Parms are traditional dash letter or dash dash name.
# Using -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding name and value to go with it).
# some arguments don't have a corresponding value to go with it such
# as in the --default example).

# Set some vars up
FALSE=1
TRUE=0

while [[ $# -gt 0 ]]
	do
		key="$1"
		case $key in
		-a|--appinstance)
			APP_INST="$2"
			shift # past argument
		;;
		-s|--subapp)
			SUB_APP="$2"
			shift # past argument
		;;
		-b|--basedirectory)
			BASE_DIR="$2"
			shift # past argument
		;;
		-g|--admingroup)
			ADMIN_GROUP="$2"
			shift # past argument
		;;
		-d|--debug)
			DEBUG_ON=$TRUE
		;;
		-c|--create)
			CREATE=$TRUE
		;;
			*)
            # unknown option
			echo "Unknown option encountered: $1"
		;;
		esac
		shift # past argument or value
done
echo "Create after args $CREATE"
}  # End cfpSetArgs

cfpSetDefaultArgs() {

#  Set defaults for any missing args that need them

if [ -z "$APP_INST" ]
  then
		APP_INST="cfpcore"   # default for app instance
fi
if [ -z "$SUB_APP" ]
  then
		SUB_APP=""   # default for sub app is to not have any
fi
if [ -z "$BASE_DIR" ]
  then
		BASE_DIR="/usr/local/"   # default for base directory
fi
if [ -z "$ADMIN_GROUP" ]
  then
		ADMIN_GROUP="cfpadmin"   # default for admin group
fi
if [ -z "$DEBUG_ON" ]
  then
		DEBUG_ON="$FALSE"   # default for set Debugging on base directory
fi
if [ -z "$CREATE" ]
  then
		CREATE="$FALSE"   # request to create dirs if not present
fi

}  # End cfpSetDefaultArgs


cfpSetApp() {

#  set script name app instance and name from caller
# export APP_INST=$1
# export SUB_APP=$2
cfpParseArgs
cfpSetDefaultArgs
cfpSetEnv

}

cfpSetEnv() {

#  root app directory and sub-directories
DEFAULT_ROOT='/usr/local'
export ROOT_DIR=$DEFAULT_ROOT/$APP_INST
export APP_DIR=$ROOT_DIR
## now loop through the array and create as needed
for dirName in "${dirList[@]}"
  do
	dirNameFull=$ROOT_DIR/${dirName^^} # Bash 4.0 and later uppercase
    export ${dirName^^}_DIR=$ROOT_DIR/$dirName
  done

# export DATA_DIR=$ROOT_DIR/data
# export BIN_DIR=$ROOT_DIR/bin
# export LOG_DIR=$ROOT_DIR/logs
# export ARCHIVE_DIR=$DATA_DIR/archive
# export LIB_DIR=$ROOT_DIR/lib

if [ -z "$SUB_APP" ] ;
  then 
  export SUB_ROOT_DIR=
  export SUB_APP_DIR=
  export SUB_DATA_DIR=
  export SUB_BIN_DIR=
  export SUB_LOG_DIR=
  export SUB_ARCHIVE_DIR=
  export SUB_LIB_DIR=
else
  export SUB_ROOT_DIR=$ROOT_DIR/$SUB_APP
  export SUB_APP_DIR=$SUB_ROOT_DIR
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
WriteLog "DEBUG_ON= $DEBUG_ON "

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
cfpCreateEnv() {
# The idea is this is run with a generated command with the following arguments
#  (defaults supplied in case not present)

cfpParseArgs
cfpSetDefaultArgs

echo APP_INST  = "${APP_INST}"
echo SUB_APP   = "${SUB_APP}"
echo BASE_DIR  = "${BASE_DIR}"
echo ADMIN_GROUP  = "${ADMIN_GROUP}"
echo DEFAULT   = "${DEFAULT}"
echo CREATE   = "${CREATE}"

export ROOT_DIR="$BASE_DIR/$APP_INST"
cfpCheckCreateDirs
ROOT_ROOT_DIR="$ROOT_DIR"  # save this

# Get Files from the location they are kept for this current data center/CSP type
# Possibly were unzipped with this file on instance creation

#TODO  fix this, like it moves the running script too!
# doing copies for now
# mv ./*.sh $ROOT_DIR/bin
# mv ./*.lib $ROOT_DIR/lib
# cp ./*.sh $ROOT_DIR/bin
# cp ./*.lib $ROOT_DIR/lib

# if [ "$SUB_APP" != "none" ]
if [ -z "$SUB_APP" ] ;
	then
		if [ ! -e $ROOT_DIR/$SUB_APP ]
			then
				echo "=== Sub App directory $ROOT_DIR/$SUB_APP not found, creating it ==="
				ROOT_DIR_HOLD=$ROOT_DIR
				export ROOT_DIR="$ROOT_ROOT_DIR/$SUB_APP"  #Set the top and do it again for sub app
				cfpCheckCreateDirs
				export ROOT_DIR="$ROOT_DIR_HOLD"  #Reset the var
		fi
fi

cfpCheckCreateGroup $ADMIN_GROUP

chgrp -R $ADMIN_GROUP $ROOT_ROOT_DIR # do this stuff regardless to make sure it didn't get undone
chmod -R 775 $ROOT_ROOT_DIR 


# Set up the environment with the app and sub-app
# echo "runnning cfpSetEnv.sh"
# source $ROOT_DIR/bin/cfpSetEnv.sh  # load environment functions (hopefully script came with)
echo "running cfpSetApp  $APP_INST $SUB_APP "
cfpSetApp  $APP_INST $SUB_APP  # set environment 
LogStart "$*"

WriteDebugLog "this is only a debugging log item"

LogStop

# End cfpCreateEnv

}

# ============================================================
#  if run stand-alone parms will be present, will call functions in order:
#  if run with no parms it will just stand-alone parms will be present, will call functions in order:
# Parms APP_INST APP_NAME
if [ $# -gt 0 ]; then
  cfpParseArgs $*
  cfpSetDefaultArgs
# echo $# $1 $2 $3
  LogStart "$*"
  if [ $CREATE -eq $TRUE ]; then
    echo "Create requested"
    cfpCreateEnv
  else
    echo "SetApp defaulted"
#	cfpSetApp $1 $2
	cfpSetEnv
#	LogStart "$*"
#	cfpShowEnv
  fi
cfpShowEnv
LogStop
fi

# End cfSetEnv.sh
