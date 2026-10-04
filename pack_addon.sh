#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 <version>"
	exit 1
fi

VERSION=$1

# cp LICENSE ./addons/scope_copy/
# cp README.md ./addons/scpe_copy/
sed -i '' "s/version=\".*\"/version=\"$VERSION\"/" ./addons/cope_copy/plugin.cfg
zip -r scope_copy-v$VERSION.zip ./addons/scope_copy -x "*.uid" "*.DS_Store"
