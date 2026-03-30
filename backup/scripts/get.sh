#!/bin/bash

set -e

echo "Job 'get' started: $(date)"

umask 0
s3cmd get -r $PARAMS  "$S3_PATH" "$DATA_PATH"

echo "Job 'get' finished: $(date)"
