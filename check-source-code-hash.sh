#!/bin/bash
# Ref. https://www.terraform.io/docs/providers/external/data_source.html

# Exit if any of the intermediate steps fail
set -ex

# Extract given arguments from the input into shell variables.
# jq will ensure that the values are properly quoted
# and escaped for consumption by the shell.
eval "$(jq -r '@sh "PACKAGE_FILE=\(.package_file) SOURCE_DIR=\(.source_dir)"')"

# Placeholder for whatever data-fetching logic your script implements
if [ ! -e $PACKAGE_FILE ]; then
    mkdir -p $(dirname $PACKAGE_FILE)
    # Generate empty file if there is no lambda package. Terraform will build an actual package later on.
    # Note that hash value in the next plan is always different because of this empty file.
    # As a result, you always see another function and layer deployment even you did not change any code in source directory.
    # This problem will be remained unless terraform allows us to update data value in plan.
    touch $PACKAGE_FILE
fi
# detect any code changes in source directory
SHA256=$(find $PACKAGE_FILE $SOURCE_DIR -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | awk '{ print $1 }')

# Debug codes
# find $PACKAGE_FILE $SOURCE_DIR -type f -print0 | sort -z | xargs -0 sha256sum > /tmp/$(basename $PACKAGE_FILE).out
# echo $SHA256 >> /tmp/$(basename $PACKAGE_FILE).out

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg sha256 "$SHA256" '{"sha256":$sha256}'
