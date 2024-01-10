# Error on < Android 8.
if [ "$API" -lt 26 ]; then
    abort "- !!! You can't use this module on Android < 8.0"
fi

# create folder to add customized settings
if [ ! -d /data/adb/trustusercerts ]; then
	mkdir -p /data/adb/trustusercerts
fi
