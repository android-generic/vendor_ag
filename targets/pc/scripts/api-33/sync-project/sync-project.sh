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
echo -e "CURRENT_pc_PATCHES_PATH: $CURRENT_pc_PATCHES_PATH"
echo -e "CURRENT_TARGET_PATH: $CURRENT_TARGET_PATH"

echo -e "variables set"

repo sync -c --force-sync --no-tags --no-clone-bundle -j$(nproc --all) --optimized-fetch --prune