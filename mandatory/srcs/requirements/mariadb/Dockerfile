FROM debian:bookworm

EXPOSE 3306

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY ./conf/99-conf.cnf /etc/mysql/mariadb.conf.d/99-conf.cnf

COPY ./tools/mariadb_entry.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/mariadb_entry.sh

CMD ["mariadb_entry.sh"]