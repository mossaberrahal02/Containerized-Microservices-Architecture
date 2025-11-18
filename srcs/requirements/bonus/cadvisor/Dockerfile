FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	wget ca-certificates && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

RUN wget -O /usr/bin/cadvisor \
    "https://github.com/google/cadvisor/releases/download/v0.47.2/cadvisor-v0.47.2-linux-amd64" && \
    chmod +x /usr/bin/cadvisor

EXPOSE 8080

CMD ["/usr/bin/cadvisor"]
