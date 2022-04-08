#!/bin/sh

# check presence of tooling

SHASUM=`which shasum`
CURL=`which curl`
[ -n ${SHASUM} ] && [ -n ${CURL} ] || exit 1

# get latest version 

URL="https://api.github.com/repos/Rigellute/spotify-tui/releases/latest"
VERSION=`curl -sL ${URL} | grep -Po '"tag_name": "v\K.*?(?=")'`

# check if it exists for windows

TARGET="https://github.com/Rigellute/spotify-tui/releases/download/v${VERSION}/spotify-tui-windows.tar.gz"

CHECKVER_CODE=`curl -X HEAD -m 3 -sfw "%{response_code}" ${TARGET}`
if [ $CHECKVER_CODE -ne 302 ]; then
	echo "Latest version ${VERSION} does not exist for windows." >&2
	exit 2
fi

echo "Latest version is v$VERSION"

SHA_URL="https://github.com/Rigellute/spotify-tui/releases/download/v${VERSION}/spotify-tui-windows.sha256"

echo "Fetching sha256"

SHA256SUM=$(curl -sLS "${SHA_URL}" | cut -c1-64)

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
      "64bit": {
        "url": "https://github.com/Rigellute/spotify-tui/releases/download/v\$version/spotify-tui-windows.tar.gz",
        "hash": {
          "url": "https://github.com/Rigellute/spotify-tui/releases/download/v\$version/spotify-tui-windows.sha256",
          "regex": "\$sha256"
        }
      }
    }
  }
}

MANIFEST

echo "Updated spotify-tui.json"
