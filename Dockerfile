FROM debian

RUN apt-get update \
	&& apt-get install -y \
		libomxil-bellagio-dev \
		git \
		build-essential \
		libass-dev \
		libmp3lame-dev \
		libx264-dev \
		cmake \
		sudo

RUN git clone --depth 1 https://github.com/raspberrypi/userland.git /tmp/userland \
	&& cd /tmp/userland \
	&& ./buildme \
	&& echo /opt/vc/lib > /etc/ld.so.conf.d/00-vmcs.conf \
	&& rm -rf /tmp/userland

RUN git clone --branch master --depth 1 https://github.com/FFmpeg/FFmpeg.git /opt/ffmpeg

RUN cd /opt/ffmpeg \
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
	# TODO: No -j4 on Pi Zero	
	&& make -j4 \
	&& make install

ENV LD_LIBRARY_PATH="/opt/vc/lib:${LD_LIBRARY_PATH}"

