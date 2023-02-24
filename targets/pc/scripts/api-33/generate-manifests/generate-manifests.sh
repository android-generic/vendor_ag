#!/bin/bash
#
# Copyright (C) 2023 Android-Generic Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

top_dir=`pwd`
LOCALDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
loc_man="${top_dir}/.repo/local_manifests"
rompath="$PWD"
vendor_path="ag"
temp_path="$rompath/vendor/$vendor_path/tmp/"
config_type="$1"
popt=0
# source $rompath/vendor/$vendor_path/ag-core/gui/easybashgui
source $ag_vendor_path/core-menu/includes/easybashgui
# include $rompath/vendor/$vendor_path/ag-core/gui/easybashgui

SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
rompath="$(dirname "$SCRIPT_PATH")"
echo -e "SCRIPT_PATH: $SCRIPT_PATH"
echo -e "rompath: $rompath"

echo -e "ag_vendor_path: $ag_vendor_path"
echo -e "temp_path: $temp_path"
echo -e "targetspath: $targetspath"
echo -e "CURRENT_pc_MANIFEST_PATH: $CURRENT_pc_MANIFEST_PATH"
manifests_url="https://raw.githubusercontent.com/android-generic/vendor_ag/unified/configs/pc"
base_manifests_path="$CURRENT_pc_MANIFEST_PATH"
echo -e "CURRENT_pc_PATCHES_PATH: $CURRENT_pc_PATCHES_PATH"
echo -e "CURRENT_TARGET_PATH: $CURRENT_TARGET_PATH"

echo -e "variables set"

echo -e "Setting up local_manifests"
mkdir -p ${loc_man}

# Parse available manifest options
preManifestsString=()
preManifestsString="$(cd $base_manifests_path && dirs=(*/); echo "${dirs[@]%/}" && cd $rompath)"

echo -e "preManifestsString: $preManifestsString"
manifestsStringArray=($preManifestsString)
for m in $preManifestsString; do
    manifestsString="$manifestsString $m"
done
echo -e "manifestsString: $manifestsString"

while :
do
menu $manifestsString
answer=$(0< "${dir_tmp}/${file_tmp}" )
#
for i in $manifestsString ; do
    if [ "${answer}" = "${i}" ]; then
    notify_message "Selected \"${i}\" ..."
    notify_change "${i}"			
    manifests_path="$base_manifests_path/${i}"
    fi
done
if [ "${answer}" = "" ]; then
    exit
fi
done

echo -e ${reset}""${reset}
echo -e ${green}"Placing manifest fragments..."${reset}
echo -e ${reset}""${reset}
if [ -d "${manifests_path}" ]; then
    cp -fpr ${manifests_path}/*.xml "${loc_man}/"
else
    echo -e ${reset}""${reset}
    echo -e ${ltblue}"INFO: Manifests not found, downloading"${reset}
    echo -e ${reset}""${reset}
    wget "${manifests_url}/00-remotes.xml" -O "${loc_man}/00-remotes.xml"
    wget "${manifests_url}/01-removes.xml" -O "${loc_man}/01-removes.xml"
    wget "${manifests_url}/02-android-x86.xml" -O "${loc_man}/02-android-x86.xml"
    wget "${manifests_url}/03-device.xml" -O "${loc_man}/03-device.xml"
    wget "${manifests_url}/04-kernel.xml" -O "${loc_man}/04-kernel.xml"
    wget "${manifests_url}/05-extras.xml" -O "${loc_man}/05-extras.xml"
    wget "${manifests_url}/05-extras.xml" -O "${loc_man}/05-extras.xml"
fi

echo -e ${reset}""${reset}
echo -e ${teal}"INFO: Cleaning up remove manifest entries"${reset}
echo -e ${reset}""${reset}
while IFS= read -r rpitem; do
    if [[ $rpitem == *"remove-project"* ]]; then
        rpitem_trimmed="$(echo "$rpitem" | xargs)"
        if grep -qRlZ "$rpitem_trimmed" "${top_dir}/.repo/manifests/"; then
            echo -e ${yellow}"WARN: ROM already includes: $rpitem"${reset}
        else
            echo -e ${green}"INFO: Needed: $rpitem"${reset}
            prefix="<remove-project name="
            suffix=" />"
            item=${rpitem_trimmed#"$prefix"}
            item=${item%"$suffix"}
            if ! grep -qRlZ "$item" "${top_dir}/.repo/manifests/"; then
                sed -e "$item"'d' "${loc_man}/01-removes.xml"
            fi
        fi
    fi
done < "${loc_man}/01-removes.xml"

echo -e ${reset}""${reset}
echo -e ${green}"Manifest generation complete. Files have been copied to $rompath/.repo/local_manifests/"${reset}
echo -e ${reset}""${reset}
