# Note: the pi3 image works for pi4 also (all Balenalib pi4 images are 64bit)
# https://www.balena.io/docs/reference/base-images/base-images-ref/
ARG BASE_IMAGE=balenalib/raspberrypi3-debian


##################################################
# FFmpeg builder
##################################################
FROM ${BASE_IMAGE} AS ffmpeg-builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        checkinstall \
        cmake \
        git \
        libass-dev \
        libmp3lame-dev \
        libomxil-bellagio-dev \
        libx264-dev \
        libx265-dev \
        sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

# We are assuming that the headers in the master match the libs
RUN git clone --depth 1 --branch master --depth=1 https://github.com/raspberrypi/firmware.git firmware

RUN git clone --branch master --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg \
    && cd ffmpeg \
    && CFLAGS="-I ../firmware/opt/vc/include/IL -I ../firmware/opt/vc/include" \
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
        --enable-mmal \
        --enable-nonfree \
        --enable-omx --enable-omx-rpi \
        --enable-pthreads \
    && make -j $(nproc) \
    && make install

WORKDIR /usr/local/src/ffmpeg

RUN checkinstall -y \
        --install=no \
        --requires "libmp3lame-dev, libass-dev, libx264-dev, libx265-dev, libatomic1" \
        --deldoc --deldesc --delspec

RUN ln -s ffmpeg*.deb ffmpeg.deb


##################################################
# Production image
##################################################
FROM ${BASE_IMAGE}

COPY --from=ffmpeg-builder /usr/local/src/ffmpeg/ffmpeg*.deb /tmp/ffmpeg.deb

RUN apt-get update \
    && apt-get install -y --no-install-recommends -f /tmp/ffmpeg.deb ffmpeg.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/ffmpeg.deb

entrypoint ["ffmpeg"]

