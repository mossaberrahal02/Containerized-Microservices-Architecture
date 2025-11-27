FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN mkdir -p /var/run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /var/run/mysqld /var/lib/mysql

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/

COPY ./tools/mariadb_entry.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb_entry.sh

EXPOSE 3306

USER mysql

ENTRYPOINT ["mariadb_entry.sh"]
CMD ["mysqld_safe"]