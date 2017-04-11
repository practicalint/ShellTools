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

## declare array of dirs/vars needed
#   (you can access them using echo "${arr[0]}", "${arr[1]}" also)
declare -a dirList=("bin" 
                	"sbin"
                	"data"
                	"log"
                	"lib"
                	"archive"
                	"etc"
                	)

#
# Functions:
#
# =====  Utility Functions  ====================================
# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)

pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}


pathremove () {
        local IFS=':'
        local NEWPATH
        local DIR
        local PATHVARIABLE=${2:-PATH}
        for DIR in ${!PATHVARIABLE} ; do
                if [ "$DIR" != "$1" ] ; then
                  NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
                fi
        done
        export $PATHVARIABLE="$NEWPATH"
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

export -f pathmunge pathremove LogStart LogStop WriteLog WriteDebugLog

# =====  Environment Management Functions  ====================================

cfpCheckCreateDirs() {
# Create the parent directory if it does not exist
# This can be called for the top instance directory or a lower App directory structure.
# The content of ROOT_DIR drives the creation

if [ ! -e $ROOT_DIR ] 
	then
		echo "=== Root directory $ROOT_DIR not found, creating it ==="
		mkdir "$ROOT_DIR" 
fi

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
egrep -i "^$ADMIN_GROUP" /etc/group;
if [ $? -eq 0 ]; then
   echo "$ADMIN_GROUP Group Exists"
else
   echo "Group $ADMIN_GROUP does not exist "
   groupadd $ADMIN_GROUP
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
		BASE_DIR="/usr/local"   # default for base directory
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


#  store the variables defining the environment to reset later
cfpStoreEnv() {

WriteLog "Storing CFP Environment Variables to ${BASE_DIR}/bin/cfpRetrieveEnv.sh "
cat << EOF > "${BASE_DIR}/bin/cfpRetrieveEnv.sh"
#!/bin/bash
source ${BIN_DIR}/cfpSetEnv.sh --appinstance ${APP_INST} --subapp ${SUB_APP} 
EOF

chown $ADMIN_GROUP ${BASE_DIR}/bin/cfpRetrieveEnv.sh
chmod +x ${BASE_DIR}/bin/cfpRetrieveEnv.sh
}

cfpSetApp() {

#  set script name app instance and name from caller
cfpParseArgs
cfpSetDefaultArgs
cfpSetEnv

}

cfpSetEnv() {

#  main app vars
export APP_INST="$APP_INST"
export SUB_APP="$SUB_APP"
#  root app directory and sub-directories
# DEFAULT_ROOT="/usr/local"
export ROOT_DIR="$BASE_DIR/$APP_INST"
export APP_DIR=$ROOT_DIR
## now loop through the array and export dir vars
for dirName in "${dirList[@]}"
  do
    dirNameFull=$ROOT_DIR/${dirName^^} # Bash 4.0 and later uppercase
    export ${dirName^^}_DIR=$ROOT_DIR/$dirName
  done

# put bin dir in path
pathmunge "$BIN_DIR" "after"
pathmunge "$SBIN_DIR" "after"

if [ -z "$SUB_APP" ] ;
  then 
    unset SUB_ROOT_DIR
    unset SUB_APP_DIR
## now loop through the array and unset to clear vars
  for dirName in "${dirList[@]}"
    do
      unset "SUB_${dirName^^}_DIR"
    done
else
  export "SUB_ROOT_DIR=$ROOT_DIR/$SUB_APP"
  export "SUB_APP_DIR=$SUB_ROOT_DIR"
## now loop through the array and export to clear vars
  for dirName in "${dirList[@]}"
    do
      dirNameFull="$SUB_ROOT_DIR/${dirName^^}" # Bash 4.0 and later uppercase
      export "SUB_${dirName^^}_DIR=$SUB_ROOT_DIR/$dirName"
    done
# put bin dir in path
    pathmunge "$SUB_BIN_DIR" "after"
    pathmunge "$SUB_SBIN_DIR" "after"
fi

# TODO: figure out how to log using called script name instead of top script name
# called=$_
# [[ $called != $0 ]] && echo "Script is being sourced" || echo "Script is being run"
# echo "\$BASH_SOURCE ${BASH_SOURCE[@]}"
# echo "0 is $0  dollar_ is $_ "

export SCRIPT_NAME="$( basename $BASH_SOURCE )"
# Timestamp format for filenames
export TIMESTAMP=`date +%Y%m%d-%H%M%S`
export ADMIN_GROUP=$ADMIN_GROUP

cfpStoreEnv
cfpShowEnv

}

#  display the variables
cfpShowEnv() {

WriteLog "Show CFP Environment Variables: "
WriteLog "SCRIPT_NAME= $SCRIPT_NAME "
WriteLog "APP_INST= $APP_INST "
WriteLog "ROOT_DIR= $ROOT_DIR "
WriteLog "APP_DIR= $APP_DIR "
## now loop through the array and export dir vars
for dirName in "${dirList[@]}"
  do
    tempName="${dirName^^}_DIR"
    WriteLog "$tempName= ${!tempName}"
  done

if [ -z "$SUB_APP" ] ;
  then 
  WriteLog "SUB_APP= none "
else
  WriteLog "SUB_APP= $SUB_APP "
  WriteLog "SUB_ROOT_DIR= $SUB_ROOT_DIR "
  WriteLog "SUB_APP_DIR= $SUB_APP_DIR "
## now loop through the array and export dir vars
for dirName in "${dirList[@]}"
  do
    tempName="SUB_${dirName^^}_DIR"
    WriteLog "$tempName= ${!tempName}"
  done
fi

WriteLog "TIMESTAMP= $TIMESTAMP "
WriteLog "DEBUG_ON= $DEBUG_ON "
WriteLog "ADMIN_GROUP= $ADMIN_GROUP "


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

if [ -z "$SUB_APP" ] ;
    then
    echo "=== No Sub App requested ==="
else
#     then
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
# echo "running cfpSetApp  $APP_INST $SUB_APP "
# cfpSetApp  $APP_INST $SUB_APP  # set environment 
cfpSetEnv  # set environment 
LogStart "$*"

WriteDebugLog "this is only a debugging log item"

LogStop

# End cfpCreateEnv

}

# ============================================================

# probably not needed if script is sourced, but makes functions available to anything running in the environment
export -f cfpSetApp cfpSetEnv 

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
    echo "SetEnv defaulted"
	cfpSetEnv
  fi
  LogStop
fi

# End cfSetEnv.sh
