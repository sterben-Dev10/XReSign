# !/bin/bash

#
#  entitlements.sh
#  XReSign
#
#  Copyright © 2017 xndrs. All rights reserved.
#

MOBILEPROV="$1"
TMPDIR="$2"

echo "Extract entitlements from mobileprovisioning"
security cms -D -i "$MOBILEPROV" > "$TMPDIR/provisioning.plist"
/usr/libexec/PlistBuddy -x -c 'Print:Entitlements' "$TMPDIR/provisioning.plist" > "$TMPDIR/entitlements.plist"

echo "SUCCESS"
