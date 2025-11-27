FROM debian:bookworm

EXPOSE 3306

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/mariadb.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb.sh

CMD ["mariadb.sh"]