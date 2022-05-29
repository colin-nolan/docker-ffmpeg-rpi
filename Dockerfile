ARG BASE_IMAGE=ubuntu


##################################################
# Userland build and setup
##################################################
FROM ${BASE_IMAGE} AS userland-builder

ENV DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-eufo", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
            build-essential \
            ca-certificates \
            cmake \
            git \
            sudo \
    && rm -rf /var/lib/apt/lists/*

# A pre-compiled copy of userland software (+ closed source binaries) are available at:
# https://github.com/raspberrypi/firmware
# However, given the binaries are going to be compiled for 32 bit, it feels like it would be more
# helpful for those on 64 bit kernels to compile a 64 bit userland
RUN git clone --branch master --depth 1 https://github.com/raspberrypi/userland.git /usr/local/src/userland \
    && cd /usr/local/src/userland \
    && ./buildme


FROM ${BASE_IMAGE} as base-with-userland

SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/opt/vc/lib"

COPY --from=userland-builder /opt/vc/lib /opt/vc/lib


##################################################
# FFmpeg build
##################################################
FROM base-with-userland AS ffmpeg-build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        libass-dev \
        libmp3lame-dev \
        libomxil-bellagio-dev \
        libvpx-dev \
        libx264-dev \
        libx265-dev \
        sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

ENV USERLAND=/usr/local/src/userland
COPY --from=userland-builder /usr/local/src/userland "${USERLAND}"

RUN git clone --branch master --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg
WORKDIR /usr/local/src/ffmpeg
RUN CFLAGS="-I ${USERLAND} -I ${USERLAND}/interface/vmcs_host/khronos/IL -I ${USERLAND}/host_applications/linux/libs/bcm_host/include" \
       ./configure \
           --extra-ldflags="-latomic" \
           --arch=armhf \
           --target-os=linux \
           --enable-gpl \
           --enable-hardcoded-tables \
           --enable-libass \
           --enable-libfreetype \
           --enable-libmp3lame \
           --enable-libx264 \
           --enable-libx265 \
           --enable-libvpx \
           --enable-mmal \
           --enable-nonfree \
           --enable-omx --enable-omx-rpi \
           --enable-pthreads \
    && make -j $(nproc)

RUN echo "libmp3lame-dev, libass-dev, libvpx-dev, libx264-dev, libx265-dev, libatomic1, libraspberrypi-dev" > apt-requirements.txt


##################################################
# Debian package build
##################################################
FROM ffmpeg-build as deb-build

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        checkinstall \
        file \
        gettext \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src/ffmpeg
RUN make install

RUN checkinstall -y \
        --type=debian \
        --pkgname=rpi-ffmpeg \
        --pkglicense=non-free \
        --install=no \
        --gzman=yes \
        --requires="$(cat apt-requirements.txt)" \
        --conflicts=ffmpeg \
        --backup=no \
        --deldoc --deldesc --delspec

RUN mv rpi-ffmpeg*.deb rpi-ffmpeg.deb


##################################################
# Asset extraction
##################################################
FROM scratch as export

COPY --from=deb-build /usr/local/src/ffmpeg/rpi-ffmpeg.deb /rpi-ffmpeg.deb
COPY --from=ffmpeg-build /usr/local/src/ffmpeg/ffmpeg /ffmpeg


##################################################
# Production image
##################################################
FROM base-with-userland as production

COPY --from=ffmpeg-build /usr/local/src/ffmpeg/ffmpeg /usr/local/bin/ffmpeg
COPY --from=ffmpeg-build /usr/local/src/ffmpeg/apt-requirements.txt /tmp/apt-requirements.txt

# Not installing libraspberrypi-dev, as we want to use the userland that ffmpeg was compiled against
# to ensure compatibility
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         $(cat /tmp/apt-requirements.txt | sed 's|, |\n|g' | egrep -v '^libraspberrypi-dev$') \
    && rm -rf /var/lib/apt/lists/* \
    && rm /tmp/apt-requirements.txt

entrypoint ["ffmpeg"]

