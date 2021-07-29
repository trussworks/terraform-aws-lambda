#! /usr/bin/env bash

set -e -o pipefail

# Setup/how to run
usage() {
    echo "Usage: $0 <url> <FILENAME> <CHECKSUM>"
    exit 1
}
[[ -z $1 || -z $2 || -z $3 ]] && usage
set -u


readonly GITHUB="https://api.github.com"

readonly REPOSITORY_PATH="${1}"
readonly FILENAME="${2}"
readonly VERSION="${3}"
readonly CHECKSUM="${4}"
readonly TOKEN="${5}"

function gh_curl() {
  curl -H "Authorization: TOKEN ${TOKEN}" \
       -H "Accept: application/vnd.github.v3.raw" \
       "$@"
}

parser=". | map(select(.tag_name == \"${VERSION}\"))[0].assets | map(select(.name == \"${FILENAME}\"))[0].id"

asset_id=$(gh_curl -s "${GITHUB}/repos/${REPOSITORY_PATH}/releases" | jq "${parser}")

if [ "${asset_id}" = "null" ]; then
  >&2 echo "ERROR: VERSION not found ${VERSION}"
  exit 1
fi

wget -q --auth-no-challenge --header='Accept:application/octet-stream' \
  "https://${TOKEN}:@api.github.com/repos/$REPOSITORY_PATH/releases/assets/${asset_id}" \
  -O "${FILENAME}"

if [ "$(sha256sum "${FILENAME}" | cut -f1 -d' ')" = "${CHECKSUM}" ]; then
    echo "The downloaded file's sha matched expected sha."
else
    echo "Error: The downloaded file's sha did not match expected sha."
    exit 1
fi
