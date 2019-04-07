#!/bin/bash

set -euf -o pipefail

scriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

pushd "${scriptDirectory}"
docker build -t colinnolan/ffmpeg-rpi:build -f Dockerfile.build .
docker build -t colinnolan/ffmpeg-rpi:latest .
popd

