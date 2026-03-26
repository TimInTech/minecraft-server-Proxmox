#!/usr/bin/env bash
set -euo pipefail

# ── PaperMC Updater ── v3.0 ──
# Uses PaperMC Fill v3 API (fill.papermc.io)

cd /opt/minecraft || exit 1

USER_AGENT="minecraft-server-Proxmox/3.0 (https://github.com/TimInTech/minecraft-server-Proxmox)"
FILL_API="https://fill.papermc.io/v3/projects/paper"

LATEST_VERSION=$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "${FILL_API}" | jq -r '.versions | last')
echo "Latest Minecraft version: ${LATEST_VERSION}"

BUILDS_JSON=$(curl -fsSL -H "User-Agent: ${USER_AGENT}" "${FILL_API}/versions/${LATEST_VERSION}/builds")

# Filter for STABLE channel; fall back to latest build if no stable exists yet
STABLE_BUILD=$(printf '%s' "$BUILDS_JSON" | jq -r '
  (map(select(.channel == "STABLE")) | sort_by(.id) | last) //
  (sort_by(.id) | last)')

if [[ -z "$STABLE_BUILD" || "$STABLE_BUILD" == "null" ]]; then
  echo "ERROR: No builds found for version ${LATEST_VERSION}" >&2
  exit 1
fi

LATEST_BUILD=$(printf '%s' "$STABLE_BUILD" | jq -r '.id')
DOWNLOAD_URL=$(printf '%s' "$STABLE_BUILD" | jq -r '.downloads."server:default".url // empty')
EXPECTED_SHA=$(printf '%s' "$STABLE_BUILD" | jq -r '.downloads."server:default".checksums.sha256 // empty')

if [[ -z "$DOWNLOAD_URL" ]]; then
  echo "ERROR: No download URL in API response for build ${LATEST_BUILD}" >&2
  exit 1
fi

echo "Downloading PaperMC build ${LATEST_BUILD}..."
curl -fL -H "User-Agent: ${USER_AGENT}" --retry 3 --retry-delay 2 -o server.jar "$DOWNLOAD_URL"

jar_size=$(stat -c '%s' server.jar)
if (( jar_size < 5242880 )); then
  echo "ERROR: Downloaded server.jar is too small (${jar_size} bytes). Likely an error page." >&2
  exit 1
fi

ACTUAL_SHA=$(sha256sum server.jar | awk '{print $1}')
if [[ -n "${EXPECTED_SHA}" && "${EXPECTED_SHA}" != "null" ]]; then
  if [[ "${ACTUAL_SHA}" != "${EXPECTED_SHA}" ]]; then
    echo "ERROR: SHA256 mismatch for PaperMC (expected ${EXPECTED_SHA}, got ${ACTUAL_SHA})" >&2
    exit 1
  fi
  echo "SHA256 verified: ${ACTUAL_SHA}"
else
  echo "WARNING: No upstream SHA provided; computed: ${ACTUAL_SHA}"
fi

echo "✅ Update complete to version ${LATEST_VERSION} (build ${LATEST_BUILD})"
