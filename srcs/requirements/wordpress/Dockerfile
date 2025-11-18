FROM debian:bookworm

EXPOSE 9000

RUN apt-get update && apt-get install -y \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-mbstring \
    php-xml \
    php-zip \
    php-json \
    php-intl \
    curl \
	ca-certificates \
	mariadb-client \
	redis-tools \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /var/www/html

COPY conf/wp-config.php /tmp/wp-config.php
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY --chmod=700 tools/wp-entrypoint.sh /usr/local/bin/wp-entrypoint.sh

CMD ["wp-entrypoint.sh"]
