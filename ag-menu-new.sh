#!/bin/sh

SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# rompath="$(dirname "$SCRIPT_PATH")"
# rompath=$(pwd)
rompath="$PWD"
export rompath="$PWD"

echo -e "SCRIPT_PATH: $SCRIPT_PATH"
echo -e "rompath: $rompath"
ag_vendor_path="$SCRIPT_PATH"
export ag_vendor_path="$ag_vendor_path"
ag_temp_path="$ag_vendor_path/tmp"
export ag_temp_path="$ag_vendor_path/tmp"
mkdir -p $ag_temp_path

targetspath="$ag_vendor_path/targets"
export targetspath="$ag_vendor_path/targets"

# source $rompath/vendor/$ag_vendor_path/ag-core/gui/easybashgui
export supericon="$ag_vendor_path/assets/ag-logo.png"

export PATH="$ag_vendor_path/core-menu/includes/:$PATH"
source $ag_vendor_path/core-menu/includes/easybashgui

# Grab PLATFORM_SDK_VERSION


if [ -f "$ag_temp_path/current_build_env.info" ]; then 

# echo -e $(cat $ag_temp_path/current_build_env.info ) | text
# echo -e "$(cat $ag_temp_path/current_build_env.info )" | text

CURRENT_PLATFORM_VERSION_LINE=`sed '2q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_VERSION=$(echo "$CURRENT_PLATFORM_VERSION_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_VERSION" != "CURRENT_PLATFORM_VERSION:" ]; then CURRENT_PLATFORM_VERSION=$TEMP_CURRENT_PLATFORM_VERSION; fi

CURRENT_PLATFORM_VERSION_LAST_STABLE_LINE=`sed '3q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_VERSION_LAST_STABLE=$(echo "$CURRENT_PLATFORM_VERSION_LAST_STABLE_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_VERSION_LAST_STABLE" != "CURRENT_PLATFORM_VERSION_LAST_STABLE:" ]; then CURRENT_PLATFORM_VERSION_LAST_STABLE=$TEMP_CURRENT_PLATFORM_VERSION_LAST_STABLE; fi

CURRENT_PLATFORM_DISPLAY_VERSION_LINE=`sed '4q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_DISPLAY_VERSION=$(echo "$CURRENT_PLATFORM_DISPLAY_VERSION_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_DISPLAY_VERSION" != "CURRENT_PLATFORM_DISPLAY_VERSION:" ]; then CURRENT_PLATFORM_DISPLAY_VERSION=$TEMP_CURRENT_PLATFORM_DISPLAY_VERSION; fi

CURRENT_PLATFORM_SDK_VERSION_LINE=`sed '5q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_SDK_VERSION=$(echo "$CURRENT_PLATFORM_SDK_VERSION_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_SDK_VERSION" != "CURRENT_PLATFORM_SDK_VERSION:" ]; then CURRENT_PLATFORM_SDK_VERSION=$TEMP_CURRENT_PLATFORM_SDK_VERSION; fi

CURRENT_BUILD_NUMBER_LINE=`sed '6q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_BUILD_NUMBER=$(echo "$CURRENT_BUILD_NUMBER_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_BUILD_NUMBER" != "CURRENT_BUILD_NUMBER:" ]; then CURRENT_BUILD_NUMBER=$TEMP_CURRENT_BUILD_NUMBER; fi

CURRENT_PLATFORM_VERSION_CODENAME_LINE=`sed '7q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_VERSION_CODENAME=$(echo "$CURRENT_PLATFORM_VERSION_CODENAME_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_VERSION_CODENAME" != "CURRENT_PLATFORM_VERSION_CODENAME:" ]; then CURRENT_PLATFORM_VERSION_CODENAME=$TEMP_CURRENT_PLATFORM_VERSION_CODENAME; fi

CURRENT_PLATFORM_SECURITY_PATCH_LINE=`sed '8q;d' $ag_temp_path/current_build_env.info`
TEMP_CURRENT_PLATFORM_SECURITY_PATCH=$(echo "$CURRENT_PLATFORM_SECURITY_PATCH_LINE" | awk '{print $NF}')
if [ "$TEMP_CURRENT_PLATFORM_SECURITY_PATCH" != "CURRENT_PLATFORM_SECURITY_PATCH:" ]; then CURRENT_PLATFORM_SECURITY_PATCH=$TEMP_CURRENT_PLATFORM_SECURITY_PATCH; fi
else 

message "collecting some info from your current Android project..."

# source build/envsetup.sh >/dev/null && setpaths
. build/envsetup.sh

echo "Gathering Info"
CURRENT_PLATFORM_SDK_VERSION=`get_build_var PLATFORM_SDK_VERSION`
CURRENT_BUILD_NUMBER=`get_build_var BUILD_NUMBER`
CURRENT_PLATFORM_VERSION_CODENAME=`get_build_var PLATFORM_VERSION_CODENAME`
CURRENT_PLATFORM_SECURITY_PATCH=`get_build_var PLATFORM_SECURITY_PATCH`
# CURRENT_BUILD_DISPLAY_ID=`get_build_var BUILD_DISPLAY_ID`
CURRENT_PLATFORM_VERSION_LAST_STABLE=`get_build_var PLATFORM_VERSION_LAST_STABLE`
CURRENT_PLATFORM_VERSION=`get_build_var PLATFORM_VERSION`
CURRENT_PLATFORM_DISPLAY_VERSION=`get_build_var PLATFORM_DISPLAY_VERSION`

echo "Showing Notification"

echo -e "Current Detected Android Info: \n" \
	"PLATFORM_VERSION: $CURRENT_PLATFORM_VERSION \n" \
	"PLATFORM_VERSION_LAST_STABLE: $CURRENT_PLATFORM_VERSION_LAST_STABLE \n" \
	"PLATFORM_DISPLAY_VERSION: $CURRENT_PLATFORM_DISPLAY_VERSION \n" \
	"PLATFORM_SDK_VERSION: $CURRENT_PLATFORM_SDK_VERSION \n" \
	"BUILD_NUMBER: $CURRENT_BUILD_NUMBER \n" \
	"PLATFORM_VERSION_CODENAME: $CURRENT_PLATFORM_VERSION_CODENAME \n" \
	"PLATFORM_SECURITY_PATCH: $CURRENT_PLATFORM_SECURITY_PATCH \n" > $ag_temp_path/current_build_env.info
fi 

echo -e "Current Detected Android Info: \n" \
	"PLATFORM_VERSION: $CURRENT_PLATFORM_VERSION \n" \
	"PLATFORM_VERSION_LAST_STABLE: $CURRENT_PLATFORM_VERSION_LAST_STABLE \n" \
	"PLATFORM_DISPLAY_VERSION: $CURRENT_PLATFORM_DISPLAY_VERSION \n" \
	"PLATFORM_SDK_VERSION: $CURRENT_PLATFORM_SDK_VERSION \n" \
	"BUILD_NUMBER: $CURRENT_BUILD_NUMBER \n" \
	"PLATFORM_VERSION_CODENAME: $CURRENT_PLATFORM_VERSION_CODENAME \n" \
	"PLATFORM_SECURITY_PATCH: $CURRENT_PLATFORM_SECURITY_PATCH \n" | text

# Figure out what kind of source we are dealing with here
CURRENT_BSP_TYPE=""
if [ -d "$rompath/vendor/rockchip" ]; then
  CURRENT_BSP_TYPE="rockchip"
elif [ -d "$rompath/vendor/mediatek" ]; then
  CURRENT_BSP_TYPE="mediatek"
elif [ -d "$rompath/vendor/lineage" ]; then
  CURRENT_BSP_TYPE="lineage"
elif [ -d "$rompath/vendor/bliss" ]; then
  CURRENT_BSP_TYPE="bliss"
fi


# Figure out targets or ask if not found
CURRENT_TARGET_TYPE=""
# Look for Android-x86 bits
# if [[ -d "$rompath/external/kernel-drivers" ]] && [[ -d "$rompath/external/mesa" ]] \
#   && [[ -d "$rompath/bootable/newinstaller" ]]; then
#   CURRENT_TARGET_TYPE="pc"
# # Look for Waydroid bits
# elif [[ -d "$rompath/device/waydroid" ]]; then
#   CURRENT_TARGET_TYPE="waydroid"
# fi

# CLI Menu Start

# Sort through flags
while test $# -gt 0
do
  case $1 in

  # Normal option processing
    -h | --help)
      echo "Usage: $0 options"
      echo "options: -h | --help: Shows this dialog"
      echo "	-d | --debug: Displays debugging info"
	  exit 0
      ;;
    -d | --debug)
      ag_debug="true";
      export ag_debug="true";
      echo "Using debugging mode..."
      ;;
  # ...

  # Special cases
    --)
      break
      ;;
    --*)
      # error unknown (long) option $1
      ;;
    -?)
      # error unknown (short) option $1
      ;;

  # FUN STUFF HERE:
  # Split apart combined short options
    -*)
      split=$1
      shift
      set -- $(echo "$split" | cut -c 2- | sed 's/./-& /g') "$@"
      continue
      ;;

  # Done with options
    *)
      break
      ;;
  esac

  # for testing purposes:
  shift
done

if [[ "$ag_debug" == "true" ]]; then
  echo -e "CURRENT_BSP_TYPE: $CURRENT_BSP_TYPE"
fi

if [ "$CURRENT_TARGET_TYPE" == "" ]; then
  preTargetsString=()
  # We will only want to present targets that are available for the current API
  # preTargetsString="generic emulator pc waydroid"
  # preTargetsString="$(cd $targetspath && ls -d */ && cd $rompath)"
  preTargetsString="$(cd $targetspath && dirs=(*/); echo "${dirs[@]%/}" && cd $rompath)"
  # preTargetsString="$(for i in $(ls -d $targetspath/*/); do echo ${i%%/}; done)"
  # preTargetsString="$(find $targetspath -maxdepth 1 -mindepth 1 -type d )"
  if [[ "$ag_debug" == "true" ]]; then
  echo -e "preTargetsString: $preTargetsString"
  fi
  targetsStringArray=($preTargetsString)
  for t in $preTargetsString; do
    export CURRENT_TARGET_PATH="$targetspath/$t"

    tstring_ok="false"
    if [ -d "$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION" ]; then
      tstring_ok="true"
      echo "$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION" > $ag_temp_path/$t-manifest.cfg
      export CURRENT_${t}_MANIFEST_PATH="$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION"
    fi
    if [ -d "$targetspath/$t/scripts/api-$CURRENT_PLATFORM_SDK_VERSION" ]; then
      tstring_ok="true"
      export CURRENT_${t}_SCRIPTS_PATH="$targetspath/$t/scripts/api-$CURRENT_PLATFORM_SDK_VERSION"
    fi
    if [ -d "$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION" ]; then
      tstring_ok="true"
      echo "$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION" > $ag_temp_path/$t-patches.cfg
      export CURRENT_${t}_PATCHES_PATH="$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION"
    fi
    
    if [ "$tstring_ok" == "true" ]; then
      targetsString="$targetsString $t"
    else
      echo "No compatible components found in $targetspath/$t/ for api-$CURRENT_PLATFORM_SDK_VERSION"
    fi
  done
  if [[ "$ag_debug" == "true" ]]; then
  echo -e "targetsString: $targetsString"
  fi

  while :
    do
    menu $targetsString
    answer=$(0< "${dir_tmp}/${file_tmp}" )
    #
    for i in $targetsString ; do
      if [ "${answer}" = "${i}" ]; then
        notify_message "Selected \"${i}\" ..."
        notify_change "${i}"			
        CURRENT_TARGET_TYPE="${i}"
        if [[ "$ag_debug" == "true" ]]; then
        bash $SCRIPT_PATH/core-menu/core-menu.sh -c $targetspath/$CURRENT_TARGET_TYPE/menus/api-$CURRENT_PLATFORM_SDK_VERSION/menu.json -d
        else
        bash $SCRIPT_PATH/core-menu/core-menu.sh -c $targetspath/$CURRENT_TARGET_TYPE/menus/api-$CURRENT_PLATFORM_SDK_VERSION/menu.json
        fi
      fi
    done
    if [ "${answer}" = "" ]; then
      exit
    fi
  done
fi
if [[ "$ag_debug" == "true" ]]; then
echo -e "CURRENT_TARGET_TYPE: $CURRENT_TARGET_TYPE"
fi
