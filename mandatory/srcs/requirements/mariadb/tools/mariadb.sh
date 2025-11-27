#!/bin/bash

set -eu

echo "from the mariadb.sh"

mysqld_safe &
MARIADB_PID=$!


until mysqladmin ping --silent 2>&1 > /dev/null; do
    echo "Waiting for MariaDB to start..."
    sleep 2
done
echo "MariaDB has started in the background."

mysql << eof
CREATE DATABASE IF NOT EXISTS $DATABASE_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_USER_PASSWORD';
GRANT ALL PRIVILEGES ON $DATABASE_NAME.* TO '$DB_USER'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASSWORD';
FLUSH PRIVILEGES;
eof

echo "MariaDB setup is complete."
echo "...stopping mariadb in the background."
mysqladmin -u root -p$DB_ROOT_PASSWORD shutdown
echo "...MariaDB is stopped."

echo "starting mariadb in foreground"
exec mysqld_safe --user=mysql