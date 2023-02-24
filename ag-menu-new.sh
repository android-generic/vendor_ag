#!/bin/bash

SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rompath="$(dirname "$SCRIPT_PATH")"
echo -e "SCRIPT_PATH: $SCRIPT_PATH"
echo -e "rompath: $rompath"
# rompath="$PWD"
ag_vendor_path="$SCRIPT_PATH"
export ag_vendor_path="$ag_vendor_path"
temp_path="$ag_vendor_path/tmp"
export temp_path="$ag_vendor_path/tmp"

targetspath="$ag_vendor_path/targets"
export targetspath="$ag_vendor_path/targets"

# source $rompath/vendor/$ag_vendor_path/ag-core/gui/easybashgui

export PATH="$ag_vendor_path/core-menu/includes/:$PATH"
source $ag_vendor_path/core-menu/includes/easybashgui

# Grab PLATFORM_SDK_VERSION

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

# PLATFORM_SDK_VERSION: 33 
# BUILD_NUMBER: eng..20230223.160143 
# PLATFORM_VERSION_CODENAME: REL 
# PLATFORM_SECURITY_PATCH: 2022-09-05 
# PLATFORM_VERSION: 13 

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
echo -e "CURRENT_BSP_TYPE: $CURRENT_BSP_TYPE"

# Figure out targets or ask if not found
CURRENT_TARGET_TYPE=""
# Look for Android-x86 bits
if [[ -d "$rompath/external/kernel-drivers" ]] && [[ -d "$rompath/external/mesa" ]] \
  && [[ -d "$rompath/bootable/newinstaller" ]]; then
  CURRENT_TARGET_TYPE="pc"
# Look for Waydroid bits
elif [[ -d "$rompath/device/waydroid" ]]; then
  CURRENT_TARGET_TYPE="waydroid"
fi
if [ "$CURRENT_TARGET_TYPE" == "" ]; then
  preTargetsString=()
  # We will only want to present targets that are available for the current API
  # preTargetsString="generic emulator pc waydroid"
  # preTargetsString="$(cd $targetspath && ls -d */ && cd $rompath)"
  preTargetsString="$(cd $targetspath && dirs=(*/); echo "${dirs[@]%/}" && cd $rompath)"
  # preTargetsString="$(for i in $(ls -d $targetspath/*/); do echo ${i%%/}; done)"
  # preTargetsString="$(find $targetspath -maxdepth 1 -mindepth 1 -type d )"
  echo -e "preTargetsString: $preTargetsString"
  targetsStringArray=($preTargetsString)
  for t in $preTargetsString; do
    if [ -d "$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION" ]; then
      targetsString="$targetsString $t"
      echo "$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION" > $temp_path/$t-manifest.cfg
      export CURRENT_${t}_MANIFEST_PATH="$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION"
    else
      echo "$targetspath/$t/manifests/api-$CURRENT_PLATFORM_SDK_VERSION was not found"
    fi
    if [ -d "$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION" ]; then
      echo "$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION" > $temp_path/$t-patches.cfg
      export CURRENT_${t}_PATCHES_PATH="$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION"
      export CURRENT_TARGET_PATH="$targetspath/$t"
      # export CURRENT_${t}_MENU_PATH="$targetspath/$t/menus/api-$CURRENT_PLATFORM_SDK_VERSION/menu.json"
    else
      echo "$targetspath/$t/patches/api-$CURRENT_PLATFORM_SDK_VERSION was not found"
    fi
  done
  echo -e "targetsString: $targetsString"

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
        bash $SCRIPT_PATH/core-menu/core-menu.sh -c $targetspath/$CURRENT_TARGET_TYPE/menus/api-$CURRENT_PLATFORM_SDK_VERSION/menu.json -d
      fi
    done
    if [ "${answer}" = "" ]; then
      exit
    fi
  done
fi

echo -e "CURRENT_TARGET_TYPE: $CURRENT_TARGET_TYPE"
# Functions Start

# Use CURRENT_PLATFORM_SDK_VERSION to see what generic addons and targets are available
# find_modules() {}

# Functions End

# CLI Menu Start

# Sort through flags
while test $# -gt 0
do
  case $1 in

  # Normal option processing
    -h | --help)
      echo "Usage: $0 options"
      echo "options: -h | --help: Shows this dialog"
      echo "	-c | --clean: cleans up downloaded apps"
      echo "	-v | --version: Shows version info"
      echo "	-s | --search | search: Searches all repos for a package"
      echo "	-l | --listrepos | listrepos: Lists all added fdroid repos"
      echo "	-a | --addrepo | addrepo (repo repo_url): Adds a new fdroid repo"
      echo "	-r | --removerepo | removerepo (repo): Removes a repo"
      echo "	-u | --updaterepo | updaterepo (repo repo_url): Updates a new fdroid repo"
      echo "	-i | --install | install (app_name): Searches for & installs an app"
      echo "	-n | --remove | remove (app_name): uninstalls an app"
      echo "	-m | --listapps | listapps: Lists all installed apps"
      echo "	-p | --apkinstall | apkinstall (apk_location): installs an apk"
	  exit 0
      ;;
    -c | --clean)
      clean="y";
      echo "Cleaning..."
	  cleanUp
      ;;
    -v | --version)
      echo "Version: Waydroid Package Manager 0.01"
      echo "Updated: 03/31/2022"
	  exit 0
      ;;
    -s | --search | search)
      SEARCH="true";
	  ;;
    -a | --addrepo | addrepo)
	  ADD_REPO="true";
      ;;
    -r | --removerepo | removerepo)
	  REMOVE_REPO="true";
      ;;
    -u | --updaterepo | updaterepo)
	  UPDATE_REPO="true";
      ;;
    -l | --listrepos | listrepos)
	  LIST_REPOS="true";
      ;;
    -i | --install | install)
	  INSTALL="true";
      ;;
    -n | --remove | remove)
	  REMOVE="true";
      ;;
    -m | --listapps | listapps)
	  LIST_APPS="true";
      ;;
    -p | --apkinstall | apkinstall)
	  APKINSTALL="true";
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