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
patch_dir="$1"

if [[ ! -d "$patch_dir" ]]; then
  echo "usage: $0 PATCH_DIR"
  exit 1
fi

patch_dir=`readlink -f "$patch_dir"`

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

current_project=""
previous_project=""
conflict=""
conflict_list=""

project_revision=""

tag_project() {
  cd $top_dir/$1
  git tag -f autopatch/`basename $patch_dir` > /dev/null
}

apply_patch() {

  pl=$1
  pd=$2

  echo -e ""
  echo -e "Applying Patches"

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
        echo -e "        ${GREEN}Applying${NC}          $i"
      else
        echo -e "        ${RED}Conflicts${NC}         $i"
        git am --abort >& /dev/null
        conflict="y"
        conflict_list=":$current_project:$conflict_list"
      fi
    else
      echo -e "        ${GREEN}Already applied${NC}   $i"
    fi
  done

  if [[ -n "$previous_project" ]]; then
    tag_project $previous_project
  fi
}

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
fi
