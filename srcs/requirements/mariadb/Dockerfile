FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/mariadb_entry.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_entry.sh

EXPOSE 3306

ENTRYPOINT ["mariadb_entry.sh"]