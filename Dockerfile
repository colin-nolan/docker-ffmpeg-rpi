ARG BASE_IMAGE=debian:buster-backports

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
        sudo \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/src

RUN git clone --depth 1 --branch master https://github.com/raspberrypi/userland.git userland \
    && cd userland \
    && ./buildme \
    && echo /opt/vc/lib > /etc/ld.so.conf.d/00-vmcs.conf

RUN git clone --branch master --depth 1 https://github.com/FFmpeg/FFmpeg.git ffmpeg \
    && cd ffmpeg \
    && ./configure \
        --arch=armel \
        --target-os=linux \
        --enable-gpl \
        --enable-omx --enable-omx-rpi \
        --enable-nonfree \
        --enable-libx264 \
        --enable-libfreetype \
        --enable-libass \
        --enable-libmp3lame \
        --enable-mmal \
    && make $(if [[ "$(arch)" != "armv6l" ]]; then echo "-j4"; fi) \
    && make install

WORKDIR /usr/local/src/ffmpeg

ENV LD_LIBRARY_PATH="/opt/vc/lib:${LD_LIBRARY_PATH}"
RUN checkinstall -y \
        --install=no \
        --requires "libmp3lame-dev, libass-dev, libx264-dev" \
        --deldoc --deldesc --delspec

RUN mv /usr/local/src/ffmpeg/ffmpeg*.deb ffmpeg.deb \
    && tar -cf userland.tar /opt/vc/lib \
    && cd .. \
    && tar -cvzf /ffmpeg.tar.gz ffmpeg


FROM ${BASE_IMAGE}

COPY --from=ffmpeg-builder /ffmpeg.tar.gz /usr/local/src/ffmpeg

RUN cd /usr/local/src/ffmpeg \
    && tar -xzvf ffmpeg.tar.gz \
    && tar -xvf userland.tar -C / \
    && apt-get update \
    && apt-get install -y --no-install-recommends -f ffmpeg.deb \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/local/src/ffmpeg

ENV LD_LIBRARY_PATH="/opt/vc/lib:${LD_LIBRARY_PATH}"

entrypoint ["ffmpeg"]

