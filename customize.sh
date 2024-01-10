# Error on < Android 8.
if [ "$API" -lt 26 ]; then
    abort "- !!! You can't use this module on Android < 8.0"
fi

# create folder to add customized settings
if [ ! -d "/data/adb/trustusercerts" ]; then
	mkdir -p /data/adb/trustusercerts
fi

if [ ! -d "/data/adb/trustusercerts/certificates" ]; then
    mkdir -p /data/adb/trustusercerts/certificates
fi

ui_print "- Completed"
ui_print "- If you want to add certificates without adding them into user certificates, please create a file named /data/adb/trustusercerts/no_user_cert and put certificates into /data/adb/trustusercerts/certificates"