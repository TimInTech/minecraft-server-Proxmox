#!/usr/bin/env bash

set -euo pipefail

cd /opt/minecraft || exit 1

LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions | last')
LATEST_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/"$LATEST_VERSION" | jq -r '.builds | last')
BUILD_JSON="$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}")"
EXPECTED_SHA="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.sha256')"
JAR_NAME="$(printf '%s' "$BUILD_JSON" | jq -r '.downloads.application.name')"

wget -O "server.jar" "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/${JAR_NAME}"
ACTUAL_SHA="$(sha256sum server.jar | awk '{print $1}')"
if [ -n "$EXPECTED_SHA" ] && [ "$EXPECTED_SHA" != "null" ]; then
  if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    echo "ERROR: SHA256 mismatch for PaperMC (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})"
    exit 1
  fi
  echo "SHA256 verified: ${ACTUAL_SHA}"
else
  echo "WARNING: No upstream SHA provided; computed: ${ACTUAL_SHA}"
fi

echo "✅ Update complete to version $LATEST_VERSION (build $LATEST_BUILD)"
