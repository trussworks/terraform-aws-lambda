#! /usr/bin/env bash

set -e -o pipefail

# Setup/how to run
usage() {
    echo "Usage: $0 <url> <expectedfilename> <expectedSHA256>"
    exit 1
}
[[ -z $1 || -z $2 || -z $3 ]] && usage
set -u

readonly url=$1
readonly expectedfilename=$2
readonly expectedSHA256=$3

# get the file
curl -sSLO "$url/$expectedfilename"

# check the file
if [ "$(sha256sum "$expectedfilename" | cut -f1 -d' ')" = "$expectedSHA256" ]; then
    echo "The downloaded file's sha matched expected sha."
else
    echo "Error: The downloaded file's sha did not match expected sha."
    exit 1
fi
