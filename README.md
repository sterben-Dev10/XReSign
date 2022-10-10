# XReSign 
XReSign allows you to sign or resign unencrypted ipa-files with certificate for which you hold the corresponding private key. Checked for developer, ad-hoc and enterprise distribution. 

## How to use

### GUI application
![Screenshot](https://github.com/sterben-Dev10/XreSign/blob/master/screenshot/screenshot.png)

### Shell command
In addition to GUI app, you can find, inside Scripts folder, xresign.sh script to run resign task from the command line.

### Usage:
```
$ ./xresign.sh -s path -c certificate [-e entitlements] [-p path] [-b identifier]

where:
-s  path to ipa file which you want to sign/resign
-c  signing certificate Common Name from Keychain
-e  new entitlements to change (Optional)
-p  path to mobile provisioning file (Optional)
-b  bundle identifier (Optional)
```
## Acknowledgments
Inspired by such great tool as iReSign and other command line scripts to resign the ipa files. Unfortunately a lot of them not supported today. So this is an attempt to support resign the app bundle components both through the GUI application and through the command line script.
