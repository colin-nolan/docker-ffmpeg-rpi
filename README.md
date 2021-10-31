# FFmpeg RPi Docker Images
_Optimised Docker images with ffmpeg for Raspberry Pi_


## Building
FFmpeg is being compiled with the `--non-free` and `--enable-gpl` flags so it cannot be distributed in binary form,
such as in a Docker image on DockerHub. Therefore, to use, you will need to build the images yourself (please ensure
you adhere to the terms of all relevant licenses).

To build the the image:
```
docker build -t colinnolan/ffmpeg-rpi:latest .
```
_Note: this may take several hours on a RPi!_

The base image can be changed by setting the `BASE_IMAGE` build arg (minimal Ubuntu is default).

Note that the ARM side libraries (e.g. mmal) are built and then linked against. According to the
[userland README](https://github.com/raspberrypi/userland#readme), 64-bit aarch64 builds of the ARM side libraries are
not (officially) supported.


## Usage
### Docker Container
`ffmpeg` is set as the image's entrypoint so the optimised tool can be easily used in a container, e.g.:
```
docker run --rm colinnolan/ffmpeg-rpi:latest --help
```
Alternatively, the image can be used as a base image for another image.

### Builder
To build the builder image (not the image that has `ffmpeg` installed):
```
docker build --target ffmpeg-builder -t colinnolan/ffmpeg-rpi-builder:latest .
```
A Debian package that can be installed in a compatible environment can be extracted from the builder image and installed:
```
docker run --rm colinnolan/ffmpeg-rpi-builder:latest cat /usr/local/src/ffmpeg/ffmpeg.deb > ffmpeg.deb
apt install ./ffmpeg.deb
```
Alterantively, the `ffmpeg` binary can be extracted for use on a system with the prerequisite dependencies:
```
docker run --rm colinnolan/ffmpeg-rpi-builder:latest cat /usr/local/src/ffmpeg/ffmpeg > ffmpeg
``` 


## Legal
The copy of FFmpeg produced is _not_ free software and must be used according to the relevant liceses of the
software that goes in its production. I am not responsible for how the products of this software are used.

I am not affiliated to FFmpeg in any way.

This work is in no way related to the company that I work for.

