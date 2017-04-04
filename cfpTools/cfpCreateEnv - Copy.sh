#!/bin/bash
#
###
# cfpCreateEnv.sh
#
# Test for and create if necessary the components of the CFP environment.
# This would normally be called at the creation of a new instance,
# but due to it's idempotent nature could be called at any time to ensure the current version of the environment exists.
###
#
# Functions:

cfpCheckCreateDirs() {
# Create the parent Instance directory if it does not exist
#if [ ! -e $ROOT_DIR ] 
if [ ! -e $ROOT_DIR ] 
	then
		echo "=== Root directory $ROOT_DIR not found, creating it ==="
		mkdir "$ROOT_DIR" 
fi

## declare array of dirs needed
#   (you can access them using echo "${arr[0]}", "${arr[1]}" also)

                
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


declare -a dirList=("bin" 
                	"data"
                	"logs"
                	"lib"
                	"archive"
                	)

# The idea is this is run with a generated command line with the following arguments
#  (defaults supplied in case not)

# parse parms into variables. Parms are traditional dash letter or dash dash name.
# Using -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding name and value to go with it).
# some arguments don't have a corresponding value to go with it such
# as in the --default example).

while [[ $# -gt 1 ]]
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
		-d|--default)
			DEFAULT=$TRUE
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

# if [ -z "$1" ]
if [ -z "$APP_INST" ]
  then
		APP_INST="cfpcore"   # default for app instance
fi
if [ -z "$SUB_APP" ]
  then
		SUB_APP="none"   # default for sub app is to have have any
fi
if [ -z "$BASE_DIR" ]
  then
		BASE_DIR="/usr/local/"   # default for base directory
fi
if [ -z "$ADMIN_GROUP" ]
  then
		ADMIN_GROUP="cfpadmin"   # default for admin group
fi
if [ -z "$DEFAULT" ]
  then
		DEFAULT="$FALSE"   # default for base directory
fi
if [ -z "$CREATE" ]
  then
		CREATE="$FALSE"   # request to create dirs if not present
fi

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
cp ./*.sh $ROOT_DIR/bin
cp ./*.lib $ROOT_DIR/lib

if [ "$SUB_APP" <> "none" ]
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
echo "runnning cfpSetEnv.sh"
source $ROOT_DIR/bin/cfpSetEnv.sh  # load environment functions (hopefully script came with)
echo "running cfpSetApp  $APP_INST $SUB_APP "
cfpSetApp  $APP_INST $SUB_APP  # set environment 
LogStart "$*"

WriteDebugLog "this is only a debugging log item"

LogStop

# End cfpCreateEnv.sh
exit 0
