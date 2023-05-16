rompath=$(pwd)

if [ ! "${ag_vendor_path}" ]; then
	SCRIPT_PATH=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	rompath="$(dirname "$SCRIPT_PATH")"
	echo -e "SCRIPT_PATH: $SCRIPT_PATH"
	echo -e "rompath: $rompath"
	# rompath="$PWD"
	ag_vendor_path="$SCRIPT_PATH"
	export ag_vendor_path="$ag_vendor_path"
fi

function apply-x86-patches
{

	vendor/${ag_vendor_path}/utils/autopatch.sh

}

function apply-x86-extras
{

	vendor/${ag_vendor_path}/utils/ap_extras.sh

}

function apply-x86-kernel-patches()
{

	vendor/${ag_vendor_path}/utils/ap_kernel.sh $1

}

function ag-menu()
{
	bash vendor/${ag_vendor_path}/ag-menu-new.sh $1 $2 $3 $4
}

function ag-menu-l()
{
	. vendor/${ag_vendor_path}/ag-menu-new.sh $1 $2 $3 $4
}

function manifest-backup
{
	bash vendor/${ag_vendor_path}/scripts/manifest-backup/manifest-backup.sh
}

function get-cros-files-x86
{
	echo "Setting up Proprietary environment for: $1"
	lunch android_x86-userdebug
	echo "Building proprietary tools... This might take a little..."
	echo "Be prepared to enter root password in order to mount the cros images and unpack things"
	cd vendor/google/chromeos-x86
	./extract-files.sh
	cd ..
	cd ..
	cd ..
}

function get-cros-files-x86_64
{
	echo "Setting up Proprietary environment for: $1"
	lunch android_x86_64-userdebug
	echo "Building proprietary tools... This might take a little..."
	echo "Be prepared to enter root password in order to mount the cros images and unpack things"
	cd vendor/google/chromeos-x86
	./extract-files.sh
	cd ..
	cd ..
	cd ..
}
