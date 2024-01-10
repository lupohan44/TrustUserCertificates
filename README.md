# Trust User Certs

This module injects all user certificates into system certificates.

This module should work on Android 8.0+. Tested on Android 14.

This module's main code logic comes from [HTTP Toolkit](https://github.com/httptoolkit/httptoolkit-server/blob/main/src/interceptors/android/adb-commands.ts)

### Installation
1. Install Magisk
2. Download latest [release](https://github.com/lupohan44/TrustUserCertificates/releases)
3. Install module through Magisk Manager

### Adding certificates
Install the certificate as a user certificate and restart the device.

### Removing certificates
Remove the certificate from the user store through the settings, and restart the device.

### [Changelog](https://github.com/lupohan44/TrustUserCertificates/blob/main/changelog.md)
