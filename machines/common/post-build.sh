#!/bin/sh

set -eu
set -f # disable globbing
export IFS=' '

echo "Uploading paths" $OUT_PATHS
nix copy --to "s3://nix-cache?scheme=http&endpoint=sergio.localdomain:9000" $OUT_PATHS &
