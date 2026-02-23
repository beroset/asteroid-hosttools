#! /bin/bash
# source the watch-util file to gain access to all of those functions
. ~/tools/AsteroidOS/asteroid-hosttools/watch-util

# handy variable to point to setup files
# For this scripts we expect the following structure
# beneath that directory.
#  .
#  +-- settings
#  +-- packages
WATCH_SETTINGS_DIR="~/projects/personal/watch"


# arbitrary delay in case we have just reflashed the watch
sleepdelay=14

# this parses some command line arguments
while [[ $# -gt 0 ]] ; do
    case $1 in 
        -a|--adb)
            ADB=true
            shift
            ;;
        -q|--qemu)
            WATCHPORT=${QEMUPORT}
            WATCHADDR=${QEMUADDR}
            shift
            ;;
        -p|--port)
            WATCHPORT="$2"
            shift
            shift
            ;;
        -r|--remote)
            WATCHADDR="$2"
            shift
            shift
            ;;
        *)
            echo "Ignoring unknown option $1"
            shift
            ;;
    esac
done 

# this waits for if the watch is not immediately detected
if ! watchPresent ; then
        waitWatch "waiting for watch..."
        echo "watch present -- sleeping for ${sleepdelay} seconds"
        sleep ${sleepdelay}
        echo "finished sleeping"
fi

# forget the ssh keys if we're connecting via ssh
if [ "${ADB}" == false ] ; then
    forgetKeys
fi

# we need to set timezone and time before we can use opkg
setTimeZone America/New_York
setTime

# customizations to set things up to make it pretty
pushWallpaper ~/tools/AsteroidOS/unofficial-watchfaces/porsche.jpg
pushWatchface ~/tools/AsteroidOS/unofficial-watchfaces/analog-weather-glow
activateWatchface analog-weather-glow

# this restores settings which were previously stored:
# to save the settings use this command:
# watch-util backup ~/projects/personal/watch/settings
restoreSettings "${WATCH_SETTINGS_DIR}"/settings
restartCeres
waitWatch "Waiting for watch"

# this sets up a DNS server and adds a route for RNDIS connection
setRouting
restartCeres
waitWatch "Waiting for watch"

# this is how you can push locally stored IPK files
pushFiles "root" ""${WATCH_SETTINGS_DIR}"/packages/*.ipk" "."

# now try to enable internet access (use previously saved WiFi credentials)
if [ "${ADB}" == false ] ; then
    setRouting
else
    doWatchCommand "root" "connmanctl enable wifi"
fi

# fetch the latest list of packages and install some favorites
doWatchCommand "root" "opkg update"
doWatchCommand "root" "opkg install asteroid-weatherfetch asteroid-qmltester asteroid-health asteroid-sensorlogd asteroid-skedaddle asteroid-virtualkeyboard cronie qtlocation vim gdbserver"
# also install the locally copied ones
doWatchCommand "root" "opkg install *.ipk"

# make sure we don't have demo mode on
doWatchCommand "root" "mcetool -D off"

# update the weather 
doWatchCommand "ceres" "weatherfetch_cli"

# this is for the picture gallery
doWatchCommand "ceres" "mkdir Pictures"
pushFiles "ceres" ""${WATCH_SETTINGS_DIR}"/packages/Pictures/*" "Pictures/"

# this is for setting up the calendar and any local qml files
pushFiles "ceres" ""${WATCH_SETTINGS_DIR}"/packages/my.ics" "."
pushFiles "ceres" ""${WATCH_SETTINGS_DIR}"/packages/*.qml" "."

# push my favorite sound as notification sound
pushFiles "root" ""${WATCH_SETTINGS_DIR}"/packages/notification.wav" "/usr/share/sounds/notification.wav"

# import previously copied calendar
doWatchCommand "ceres" "icalconverter import -d my.ics"

# make sure sensorlogd starts logging
doWatchCommand "ceres" "systemctl --user restart asteroid-sensorlogd"
