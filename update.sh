#!/bin/bash

set -euo pipefail

cd /opt/minecraft || exit 1

LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions | last')
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/"$LATEST_VERSION" | jq -r '.builds | last')

wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$LATEST_VERSION/builds/$LATEST_BUILD/downloads/paper-$LATEST_VERSION-$LATEST_BUILD.jar"

echo "✅ Update complete to version $LATEST_VERSION (build $LATEST_BUILD)"
