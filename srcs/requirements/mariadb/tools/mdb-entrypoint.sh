#!/bin/bash
set -eu

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">>>>>>>>>>>>>>Initializing MySQL data directory..."
	mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
else
	echo ">>>>>>>>>>>>>>Data directory is initialized"
fi

chown -R mysql:mysql /var/lib/mysql

echo ">>>>>>>>>>>>>>Start mysqld in background"
mysqld --skip-networking --socket=/tmp/mysql.sock &

MYSQL_PID=$!

echo ">>>>>>>>>>>>>>Waiting..."
DB_ROOT_PASS=$(cat ${DB_ROOT_PASSWORD_FILE})
until mysqladmin --socket=/tmp/mysql.sock ping --silent >/dev/null 2>&1 \
	|| mysqladmin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASS}" ping --silent >/dev/null 2>&1
do
	echo ">>>>>>>>>>>>>>Sleeping..."
	sleep 1;
done

echo ">>>>>>>>>>>>>>Mariadb is up!"

MARIADB="mariadb -u root --socket=/tmp/mysql.sock"
if mysqladmin --socket=/tmp/mysql.sock ping --silent >/dev/null 2>&1; then
	MARIADB="mariadb -u root -p${DB_ROOT_PASS} --socket=/tmp/mysql.sock"
fi

echo ">>>>>>>>>>>>>>Create database and its user and alter root"
DB_PASS=$(cat ${DB_PASSWORD_FILE})
${MARIADB} << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EOF

echo ">>>>>>>>>>>>>>Stopping temporary MySQL instance..."
kill $MYSQL_PID
wait $MYSQL_PID

echo ">>>>>>>>>>>>>>Starting MySQL server..."
mysqld
