#!/bin/bash
# -*- coding: utf-8; tab-width: 4; c-basic-offset: 4; indent-tabs-mode: nil -*-

# autopatch.sh: script to manage patches on top of repo
# Copyright (c) 2018, Intel Corporation.
# Author: sgnanase <sundar.gnanasekaran@intel.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms and conditions of the GNU General Public License,
# version 2, as published by the Free Software Foundation.
#
# This program is distributed in the hope it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.

top_dir=`pwd`

source $ag_vendor_path/core-menu/includes/easybashgui
# include $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

if [[ "$ag_debug" == "true" ]]; then
echo -e "SCRIPT_PATH: $SCRIPT_PATH"
echo -e "rompath: $rompath"
echo -e "ag_vendor_path: $ag_vendor_path"
echo -e "ag_temp_path: $ag_temp_path"
echo -e "targetspath: $targetspath"
echo -e "CURRENT_pc_MANIFEST_PATH: $CURRENT_pc_MANIFEST_PATH"
echo -e "CURRENT_pc_PATCHES_PATH: $CURRENT_pc_PATCHES_PATH"
echo -e "CURRENT_TARGET_PATH: $CURRENT_TARGET_PATH"
fi
# manifests_url="https://raw.githubusercontent.com/android-generic/vendor_ag/unified/configs/pc"
base_manifests_path="$CURRENT_pc_MANIFEST_PATH"
echo -e "variables set"


#setup colors
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
blue=`tput setaf 4`
purple=`tput setaf 5`
teal=`tput setaf 6`
light=`tput setaf 7`
dark=`tput setaf 8`
ltred=`tput setaf 9`
ltgreen=`tput setaf 10`
ltyellow=`tput setaf 11`
ltblue=`tput setaf 12`
ltpurple=`tput setaf 13`
CL_CYN=`tput setaf 12`
CL_RST=`tput sgr0`
reset=`tput sgr0`
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
current_project=""
previous_project=""
conflict=""
conflict_list=""
goodpatch=""
project_revision=""

# Use new CURRENT_pc_PATCHES_PATH variable fir patchdir and resolutions dir
pre_patch_dir="$CURRENT_pc_PATCHES_PATH/addons"
pre_roms_patch_dir="$pre_patch_dir-resolutions"


tag_project() {
  cd $top_dir/$1
  git tag -f autopatch/`basename $patch_dir` > /dev/null
}

apply_patch() {

  pl=$1
  pd=$2

  echo -e ${reset}""${reset}
  echo -e ${teal}"Applying Patches"${reset}
  echo -e ${reset}""${reset} 

  for i in $pl
  do
    current_project=`dirname $i`
    if [[ $current_project != $previous_project ]]; then
      if [[ -n "$previous_project" ]]; then
        tag_project $previous_project
      fi
      echo -e ""
      echo -e "Project ${BLUE}$current_project${NC}"
      echo -e ""
      cd $top_dir
      project_revision=`repo info $current_project | grep 'Current revision: ' | sed 's/Current revision: //'`
    fi
    previous_project=$current_project

    conflict_project=`echo $conflict_list | grep ":$current_project:"`
    if [[ -n "$conflict_project" ]]; then
      echo -e "        ${YELLOW}Skipping${NC}          $i"
      continue
    fi

    cd $top_dir/$current_project
    a=`grep "Date: " $pd/$i | sed -e "s/Date: //"`
    b=`grep "Subject: " $pd/$i | sed -e "s/Subject: //" | sed -e "s/^\[PATCH[^]]*\] //"`
    c=`git log --pretty="format:%aD, %s" $project_revision.. | grep -F "$a, $b"`

    if [[ "$c" == "" ]] ; then
      git am -3 $pd/$i >& /dev/null

      if [[ $? == 0 ]]; then
        echo -e ${reset}""${reset}
        echo -e ${ltgreen}"        Applying          $i"${reset}
        echo -e ${reset}""${reset}
      else
        echo -e ${reset}""${reset}
        echo -e ${ltred}"        Conflicts         $i"${reset}
        echo -e ${reset}""${reset}
		git am --abort >& /dev/null

		echo "                Searching other vendors for patch resolutions..."
        for agvendor in "$roms_patch_dir"/*/ ; do
            agvendor_name=$(echo ${d%%/} | sed 's|.*/||')
			echo "                looking in $agvendor_name for that patch..."
			if [[ -f "${agvendor}${i}" ]]; then
				echo "                Found ${agvendor}${i}!!"
				echo "                trying..."
				git am -3 "${agvendor}${i}" >& /dev/null
				if [[ $? == 0 ]]; then
					echo "                Applying          $i $?"
					goodpatch="y"
					break
				else
					echo "                Conflicts          $i"
					git am --abort >& /dev/null
					conflict="y"
				fi
			fi
		done
		if [[ "$goodpatch" != "y" ]]; then
			echo "                No resolution was found"
			git am --abort >& /dev/null
			echo "                Setting $i as Conflicts"
			conflict="y"
      conflict_list=":$current_project:$conflict_list"
		fi
      fi
    else
	  echo -e ${reset}""${reset}
    echo -e "        ${GREEN}Already applied${NC}   $i"
	  echo -e ${reset}""${reset}
    fi
  done

  if [[ -n "$previous_project" ]]; then
    tag_project $previous_project
  fi
}

# Parse available base options
preBaseString=()
preBaseString="$(cd $pre_patch_dir && dirs=(*/); echo "${dirs[@]%/}" && cd $rompath)"

if [[ "$ag_debug" == "true" ]]; then
echo -e "preBaseString: $preBaseString"
fi
baseStringArray=($preBaseString)
for m in $preBaseString; do
    baseString="$baseString $m"
done
if [[ "$ag_debug" == "true" ]]; then
echo -e "baseString: $baseString"
fi

ok_message "Please choose from available base types on the next screen."
while :
do
    menu $baseString
    answer=$(0< "${dir_tmp}/${file_tmp}" )
    #
    if [[ "$ag_debug" == "true" ]]; then
    echo -e "answer: ${answer}"
    fi
    for bs in $baseString ; do
        if [[ "$ag_debug" == "true" ]]; then
        echo -e "bs: $bs"
        fi
        if [ "*${answer}*" = "*${bs}*" ]; then
        notify_message "Selected \"${bs}\" ..."
        # notify_change "${i}"

        # Use new CURRENT_pc_PATCHES_PATH variable fir patchdir and resolutions dir
        patch_dir="$pre_patch_dir/${bs}"
        roms_patch_dir="$pre_roms_patch_dir/${bs}"
        
        #Apply common patches
        cd $patch_dir
        patch_list=`find * -iname "*.patch" | sort -u`

        apply_patch "$patch_list" "$patch_dir"

        echo ""
        if [[ "$conflict" == "y" ]]; then
          echo -e "${YELLOW}===========================================================================${NC}"
          echo -e "${YELLOW}           ALERT : Conflicts Observed while patch application !!           ${NC}"
          echo -e "${YELLOW}===========================================================================${NC}"
          for i in `echo $conflict_list | sed -e 's/:/ /g'` ; do echo $i; done | sort -u
          echo -e "${YELLOW}===========================================================================${NC}"
          echo -e "${YELLOW}WARNING: Please resolve Conflict(s). You may need to re-run build...${NC}"
          # return 1
        else
          echo -e "${GREEN}===========================================================================${NC}"
          echo -e "${GREEN}           INFO : All patches applied fine !!                              ${NC}"
          echo -e "${GREEN}===========================================================================${NC}"

          echo "True" > $ag_temp_path/base_patches_applied
        fi
        [[ $_ != $0 ]] && exit 0 2>/dev/null || return 0 2>/dev/null;
        fi
    done
    if [ "${answer}" = "" ]; then
        exit
    fi
done
