FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends vsftpd && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

COPY --chmod=755 tools/ftp-entrypoint.sh .
COPY --chmod=644 conf/vsftpd.conf /etc/vsftpd.conf

CMD ["./ftp-entrypoint.sh"]
