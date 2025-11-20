FROM debian:bookworm

EXPOSE 3306

RUN apt-get update && apt-get instal -y --no-install-recommends \
    mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY ./conf/99-cnf.cnf /etc/mysql/mariadb.conf.d/99-cnf.cnf
COPY --chmod=755 ./tools/mariadb_entrypoint.sh /usr/local/bin/mariadb_entrypoint.sh

CMD ["mariadb_entrypoint.sh"]