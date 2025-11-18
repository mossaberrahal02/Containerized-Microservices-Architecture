FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
	php \
	php-mysql \
	wget && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean


RUN wget https://www.adminer.org/latest.php -O adminer.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "adminer.php"]
