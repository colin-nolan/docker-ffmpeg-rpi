#!/bin/bash

set -euf -o pipefail

scriptDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dpkg -i "${scriptDirectory}/ffmpeg.deb"

tar -xzvf "${scriptDirectory}/userland.tar.gz" /opt/vc/lib

