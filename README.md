# Trust User Certs

This module injects all user certificates into system certificates.

This module should work on Android 8.0+. Tested on Android 14.

This module's main code logic comes from [HTTP Toolkit](https://github.com/httptoolkit/httptoolkit-server/blob/main/src/interceptors/android/adb-commands.ts)

### Installation
1. Install Magisk
2. Download latest [release](https://github.com/lupohan44/TrustUserCertificates/releases)
3. Install module through Magisk Manager
4. (Optional) create a file named /data/adb/trustusercerts/no_user_cert and put certificates into /data/adb/trustusercerts/certificates - This step will make module using certificates from this folder instead of user certificates

### Adding certificates
Depending on have you done step 4 in installation, you need to install the certificate as a user certificate or put the certificate into /data/adb/trustusercerts/certificates

Then, you need to reboot your phone

### Removing certificates
Depending on have you done step 4 in installation, you need to remove the certificate as a user certificate or remove the certificate from /data/adb/trustusercerts/certificates

Then, you need to reboot your phone.

### TODO
* Try to fix with monitor_user_certificate_folder, phone will reboot when add/remove certificate

### [Changelog](https://github.com/lupohan44/TrustUserCertificates/blob/main/changelog.md)
