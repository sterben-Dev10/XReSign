# !/bin/bash

#
#  xresign.sh
#  XReSign
#
#  Copyright © 2017 xndrs. All rights reserved.
#

usage="Usage example:
$(basename "$0") -s path -c certificate [-e entitlements] [-p path] [-b identifier]

where:
-s  path to ipa file which you want to sign/resign
-c  signing certificate Common Name from Keychain
-e  new entitlements to change (Optional)
-p  path to mobile provisioning file (Optional)
-b  bundle identifier (Optional)"


while getopts s:c:e:p:b: option
do
    case "${option}"
    in
      s) SOURCEIPA=${OPTARG}
         ;;
      c) DEVELOPER=${OPTARG}
         ;;
      e) ENTITLEMENTS=${OPTARG}
         ;;
      p) MOBILEPROV=${OPTARG}
         ;;
      b) BUNDLEID=${OPTARG}
         ;;
     \?) echo "invalid option: -$OPTARG" >&2
         echo "$usage" >&2
         exit 1
         ;;
      :) echo "missing argument for -$OPTARG" >&2
         echo "$usage" >&2
         exit 1
         ;;
    esac
done


echo "Start (re)sign the app..."

OUTDIR=$(dirname "${SOURCEIPA}")
TMPDIR="$OUTDIR/tmp"
APPDIR="$TMPDIR/app"


mkdir -p "$APPDIR"
unzip -qo "$SOURCEIPA" -d "$APPDIR"

APPLICATION=$(ls "$APPDIR/Payload/")
APP_PATH="$APPDIR/Payload/$APPLICATION"


if [ -z "${MOBILEPROV}" ]; then
    echo "Sign process using existing provisioning profile from payload"
else
    echo "Coping provisioning profile into application payload"
    cp "$MOBILEPROV" "$APP_PATH/embedded.mobileprovision"
fi

echo "Extract entitlements from mobileprovision"
if [ -z "${ENTITLEMENTS}" ]; then
    security cms -D -i "$APP_PATH/embedded.mobileprovision" > "$TMPDIR/provisioning.plist"
    /usr/libexec/PlistBuddy -x -c 'Print:Entitlements' "$TMPDIR/provisioning.plist" > "$TMPDIR/entitlements.plist"
else
    cp ${ENTITLEMENTS} "$TMPDIR/entitlements.plist"
    echo "${ENTITLEMENTS}"
fi

if [ -z "${BUNDLEID}" ]; then
    echo "Sign using existing bundle identifier from payload"
else
    echo "Changing bundle identifier with: $BUNDLEID"
    /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLEID" "$APP_PATH/Info.plist"
fi


echo "Get list of components and sign with certificate: $DEVELOPER"
find -d "$APP_PATH" \( -name "*.app" -o -name "*.appex" -o -name "*.framework" -o -name "*.dylib" \) > "$TMPDIR/components.txt"

echo "Sign plugins, frameworks, dylibs"
var=$((0))
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *".appex" ]]; then
        if [[ ! -z "${BUNDLEID}" ]]; then
            echo "Changing .appex bundle identifier with: $BUNDLEID.extra$var"
            /usr/libexec/PlistBuddy -c "Set:CFBundleIdentifier $BUNDLEID.extra$var" "$line/Info.plist"
            var=$((var+1))
        fi
        /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$TMPDIR/entitlements.plist" "$line"
    elif [[ "$line" == *".framework" ]]; then
        /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$TMPDIR/entitlements.plist" "$line"
    elif [[ "$line" == *".dylib" ]]; then
        /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$TMPDIR/entitlements.plist" "$line"
    fi
done < "$TMPDIR/components.txt"

echo "Sign app"
while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *".app" ]]; then
       /usr/bin/codesign --continue -f -s "$DEVELOPER" --entitlements "$TMPDIR/entitlements.plist" "$line"
    fi
done < "$TMPDIR/components.txt"


cd "$APPDIR"
filename=$(basename "$APPLICATION")
filename="${filename%.*}-xresign.ipa"
echo "Creating the signed ipa: ${filename}"
zip -qr "../$filename" *
cd ..
mv "$filename" "$OUTDIR"


echo "Clear temporary files"
rm -rf "$APPDIR"
rm "$TMPDIR/components.txt"
rm "$TMPDIR/provisioning.plist"
rm "$TMPDIR/entitlements.plist"

echo "XReSign FINISHED"
