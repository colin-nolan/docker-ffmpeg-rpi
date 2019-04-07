# ffmpeg-rpi-docker
_Docker images with ffmpeg for Raspberry Pi_

## How to Use
ffmpeg is being compiled with the `--non-free` and `--enable-gpl` flags so it cannot be distributed in binary form,
such as in a Docker image on DockerHub. Therefore, to use, you will need to build the images yourself (please ensure
you adhere to the terms of all relevant licenses).

Firstly, you need to build the image that compiles ffmpeg:
```
docker build -t colinnolan/ffmpeg-rpi:build -f Dockerfile.build .
```

Then go on to build the image with ffmpeg installed (and none of the assocaited build environment):
```
docker build -t colinnolan/ffmpeg-rpi:latest .
```

