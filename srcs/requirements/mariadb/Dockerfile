FROM debian:bookworm

EXPOSE 3306

RUN apt-get update && apt-get install -y --no-install-recommends \
	mariadb-server && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean

RUN mkdir /run/mysqld && chown -R mysql:mysql /run/mysqld

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY --chmod=755 ./tools/mdb-entrypoint.sh /usr/local/bin/

CMD ["mdb-entrypoint.sh"]
