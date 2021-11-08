# FFmpeg RPi Docker Images
_Optimised Docker images with ffmpeg for Raspberry Pi_


## Building
FFmpeg is compiled with the `--non-free` and `--enable-gpl` flags so it may not be distributable in binary form,
such as in a Docker image on DockerHub. Therefore, to use, you will need to build the images yourself (please 
ensure you adhere to the terms of all relevant licenses).

To build the the image:
```bash
docker build -t colinnolan/ffmpeg-rpi:latest .
```
_Note: this may take several hours on a RPi!_

The base image can be changed by setting the `BASE_IMAGE` build arg (`ubuntu` is default), e.g.
```bash
docker build --build-arg BASE_IMAGE=debian:buster -t colinnolan/ffmpeg-rpi:latest .
```

Note that the ARM side libraries (e.g. mmal) are built and then linked against. According to the
[userland README](https://github.com/raspberrypi/userland#readme), 64-bit aarch64 builds of the ARM side libraries are
not (officially) supported.


## Usage
### As a Docker Container
`ffmpeg` is set as the image's entrypoint so the optimised tool can be easily used in a container, e.g.:
```bash
docker run --rm colinnolan/ffmpeg-rpi:latest --help
```
Alternatively, the image can be used as a base image for another image.

### Outside of Docker
The Dockerfile can be used to build FFmpeg for use outside of Docker. A dedicated `export` stage exists to easily enable this:
```bash
docker build --target export --output /tmp/output .
```

The output directory contains two files - the FFmpeg binary and a Debian package that can be used for installations:
```text
ffmpeg
rpi-ffmpeg.deb
```

The binary can be used directly if the machine it is run on has the required dependencies installed (e.g. check 
`ldd /tmp/output/ffmpeg` for missing shared objects). It can be installed using:
```bash
mv /tmp/output/ffmpeg /usr/local/bin/ffmpeg
```
and will then be available on the PATH, i.e.
```bash
ffmpeg --help
```

Alternatively, the Debian package can be installed with:
```bash
apt install /tmp/output/rpi-ffmpeg.deb
```
This installs `ffmpeg` onto the path, along with the required dependencies.

_Note: if the `ffmpeg` binary complains about missing shared objects, it may be because the machine it is ran
on has incompatible versions of the dependencies that it was compiled against. This may be fixable by setting
`BASE_IMAGE` on the build to the same OS as that on the target machine. If this does not work, it may be because 
FFmpeg is built against the latest [userland](https://github.com/raspberrypi/userland) libraries but those 
installed on the target machine are not new enough (and would need updating)._


## Legal
The copy of FFmpeg produced is _not_ free software and must be used according to the relevant liceses of the
software that goes in its production. I am not responsible for how the products of this software are used.

I am not affiliated to FFmpeg in any way.

This work is in no way related to the company that I work for.

