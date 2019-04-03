FROM debain

COPY --from=colinnolan/ffmpeg-rpi:build /ffmpeg.tar.gz /tmp

RUN tar -xzvf /tmp/ffmpeg.tar.gz \
	&& /tmp/ffmpeg/install.sh \
	&& rm -rf /tmp/ffmpeg

