#!/bin/bash

set -euf -o pipefail

scriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

tar -xvf "${scriptDirectory}/userland.tar" -C /

apt-get update
apt install -y -f "${scriptDirectory}/ffmpeg.deb"
rm -rf /var/lib/apt/lists/*
