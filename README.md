# ffmpeg-rpi-docker
_Docker images with ffmpeg for Raspberry Pi_

## How to Use
ffmpeg is being compiled with the `--non-free` and `--enable-gpl` flags so it cannot be distributed in binary form,
such as in a Docker image on DockerHub. Therefore, to use, you will need to build the images yourself (please ensure
you adhere to the terms of all relevant licenses).

To build the the image:
```
docker build -t colinnolan/ffmpeg-rpi:latest .
```


## Legal
The copy of FFmpeg produced is _not_ free software and must be used according to the relevant liceses of the
software that goes in its production. I am not responsible for how the products of this software are used.

I am not affiliated to the development of FFmpeg in any way.

This work is in no way related to the company that I work for.

