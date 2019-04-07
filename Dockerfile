FROM debian

COPY --from=colinnolan/ffmpeg-rpi:build /ffmpeg.tar.gz /tmp

RUN tar -xzvf /tmp/ffmpeg.tar.gz -C /tmp \
	&& /tmp/ffmpeg/install.sh \
	&& rm -rf /tmp/ffmpeg

ENV LD_LIBRARY_PATH="/opt/vc/lib:${LD_LIBRARY_PATH}"

