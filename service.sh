#!/system/bin/sh
function log() {
    echo "$(date '+%m-%d %H:%M:%S [trustusercerts]')" "$@" >> /cache/magisk.log
}

function inject_into_apex() {
    # Deal with the APEX overrides in Android 14+, which need injecting into each namespace:
    if [ -d "/apex/com.android.conscrypt/cacerts" ]; then
        log "Injecting certificates into APEX cacerts"

        # When the APEX manages cacerts, we need to mount them at that path too. We can't do
        # this globally as APEX mounts are namespaced per process, so we need to inject a
        # bind mount for this directory into every mount namespace.

        # First we get the Zygote process(es), which launch each app
        ZYGOTE_PID=$(pidof zygote || true)
        ZYGOTE64_PID=$(pidof zygote64 || true)
        Z_PIDS="$ZYGOTE_PID $ZYGOTE64_PID"
        # N.b. some devices appear to have both, some have >1 of each (!)

        # Apps inherit the Zygote's mounts at startup, so we inject here to ensure all newly
        # started apps will see these certs straight away:
        for Z_PID in $Z_PIDS; do
            if [ -n "$Z_PID" ]; then
                nsenter --mount=/proc/$Z_PID/ns/mnt -- \
                    /bin/mount --bind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts
            fi
        done

        log "Zygote APEX certificates remounted"

        # Then we inject the mount into all already running apps, so they see these certs immediately.

        # Get the PID of every process whose parent is one of the Zygotes:
        APP_PIDS=$(
            echo $Z_PIDS | \
            xargs -n1 ps -o 'PID' -P | \
            grep -v PID
        )

        # Inject into the mount namespace of each of those apps:
        for PID in $APP_PIDS; do
            nsenter --mount=/proc/$PID/ns/mnt -- \
                /bin/mount --bind /system/etc/security/cacerts /apex/com.android.conscrypt/cacerts &
        done
        wait # Launched in parallel - wait for completion here

        log "APEX certificates remounted for $(echo $APP_PIDS | wc -w) apps"
    fi
}

function monitor_user_certificate_folder() {
    folder="/data/misc/user/0/cacerts-added/"
    current_file_list=$(ls "$folder")
    file_names_variable=$(cat /data/local/tmp/trustusercerts/current_file_list.txt)
    destination="/system/etc/security/cacerts/"
    need_to_inject_into_apex=false

    # Create temporary files for sorting
    current_sorted=$(mktemp)
    variable_sorted=$(mktemp)

    # Sort and save the current file list
    echo "$current_file_list" | tr ' ' '\n' | sort > "$current_sorted"

    # Sort and save the variable file list
    echo "$file_names_variable" | tr ' ' '\n' | sort > "$variable_sorted"

    # Compare files and find added and deleted files
    added_files=$(comm -13 "$variable_sorted" "$current_sorted")
    deleted_files=$(comm -13 "$current_sorted" "$variable_sorted")

    # Copy added files to the destination
    for file in $added_files; do
        cp "$folder/$file" "$destination"
        # Update the perms & selinux context labels, so everything is as readable as before
        chown root:root "$destination/$file"
        chmod 644 "$destination/$file"
        chcon u:object_r:system_file:s0 "$destination/$file"
        log "Detected new certificate $file, added to $destination"
        need_to_inject_into_apex=true
    done

    # Delete deleted files from the destination
    for file in $deleted_files; do
        echo "$file"
        if [ -f "$destination/$file" ]; then
            rm "$destination/$file"
            log "Detected deleted certificate $file, removed from $destination"
            need_to_inject_into_apex=true
        fi
    done
    if [ "$need_to_inject_into_apex" = true ]; then
        log "Injecting certificates into APEX cacerts"
        inject_into_apex
    fi
    # Update the variable for future comparison
    echo "$current_file_list" > /data/local/tmp/trustusercerts/current_file_list.txt

    # Remove temporary files
    rm "$current_sorted" "$variable_sorted"
}

# Wait for boot to complete
while [ "$(getprop sys.boot_completed)" != 1 ]; do
    /system/bin/sleep 1s
done

# Create a temp directory for the module
if [ -d "/data/local/tmp/trustusercerts" ]; then
    rm -r /data/local/tmp/trustusercerts
fi

mkdir -p /data/local/tmp/trustusercerts

# Create a separate temp directory, to hold the current certificates
# Without this, when we add the mount we can't read the current certs anymore.
mkdir -p -m 700 /data/local/tmp/tuc-ca-copy

# Copy out the existing certificates
if [ -d "/apex/com.android.conscrypt/cacerts" ]; then
	cp /apex/com.android.conscrypt/cacerts/* /data/local/tmp/tuc-ca-copy/
else
	cp /system/etc/security/cacerts/* /data/local/tmp/tuc-ca-copy/
fi

# Create the in-memory mount on top of the system certs folder
mount -t tmpfs tmpfs /system/etc/security/cacerts

# Copy the existing certs back into the tmpfs mount, so we keep trusting them
mv /data/local/tmp/tuc-ca-copy/* /system/etc/security/cacerts/

# Copy our new cert in, so we trust that too
cp /data/misc/user/0/cacerts-added/* /system/etc/security/cacerts/

# Update the perms & selinux context labels, so everything is as readable as before
chown root:root /system/etc/security/cacerts/*
chmod 644 /system/etc/security/cacerts/*
chcon u:object_r:system_file:s0 /system/etc/security/cacerts/*

log "System cacerts setup completed"

inject_into_apex

# Delete the temp cert directory & this script itself
rm -r /data/local/tmp/tuc-ca-copy

log "System cert successfully injected"

file_list=$(ls "/data/misc/user/0/cacerts-added/")
echo "$file_list" > /data/local/tmp/trustusercerts/current_file_list.txt

# Monitor the user certificate folder for changes
while true; do
    monitor_user_certificate_folder
    /system/bin/sleep 5s
done