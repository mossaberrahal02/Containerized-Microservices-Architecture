FROM debian:bookworm

EXPOSE 9000

# mariadb-client for mysqladmin ping
# php-mysql to connect to MariaDB
# /var/www/html is the default web root directory for most web servers (like Nginx or Apache).
# www-data is the default user/group that web servers (like Nginx or Apache) and PHP-FPM run as

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-fpm \
    curl \
    tar \
    mariadb-client \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN mkdir -p /var/www/html && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xvzf latest.tar.gz --strip-components=1 -C /var/www/html

RUN chown -R www-data:www-data /var/www/html

RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/wordpress.sh /usr/local/bin/wordpress.sh
RUN chmod +x /usr/local/bin/wordpress.sh

CMD ["wordpress.sh"]