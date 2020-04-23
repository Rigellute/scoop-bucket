#!/bin/sh
VERSION=$1

# check presence of version
if [ -z $VERSION ]; then
	echo "Missing argument with version" >&2
	exit 1
fi 

# check presence of tooling
SHASUM=`which shasum`
CURL=`which curl`
[ -n ${SHASUM} ] && [ -n ${CURL} ] || exit 2

TARGET="https://github.com/Rigellute/spotify-tui/releases/download/v${VERSION}/spotify-tui-windows.tar.gz"

CHECKVER_CODE=`curl -X HEAD -m 3 -sfw "%{response_code}" ${TARGET}`
if [ $CHECKVER_CODE -ne 302 ]; then
	echo "Version ${VERSION} does not exist" >&2
	exit 3
fi

SHA_URL="https://github.com/Rigellute/spotify-tui/releases/download/v${VERSION}/spotify-tui-windows.sha256"

echo "Fetching sha256"
SHA256SUM=$(curl -sLS "${SHA_URL}" | tr -d "\n\r")

cat > spotify-tui.json <<MANIFEST  
{
  "homepage": "https://github.com/Rigellute/spotify-tui",
  "description": "Spotify for the terminal",
  "version": "${VERSION}",
  "license": "MIT",
  "architecture": {
    "64bit": {
      "url": "${TARGET}",
      "hash": "${SHA256SUM}"
    }
  },
  "bin": "spt.exe",
  "checkver": "github",
  "autoupdate": {
    "architecture": {
      "url": "https://github.com/Rigellute/spotify-tui/releases/download/v\$version/spotify-tui-windows.tar.gz",
      "hash": {
        "url": "https://github.com/Rigellute/spotify-tui/releases/download/v\$version/spotify-tui-windows.sha256"
      }
    }
  }
}

MANIFEST
