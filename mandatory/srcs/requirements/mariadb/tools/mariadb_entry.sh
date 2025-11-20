#!/bin/bash


set -eu


# Checks if the directory /var/lib/mysql/mysql exists or not
# If it does not exist, it initializes the MySQL data directory by creating necessary system tables like mysql.user, mysql.db, etc.


# if [ ! -d "/var/lib/mysql/mysql" ]; then
#     echo "Initializing MySQL data directory..."
#     mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
# else
#     echo "Data directory is initialized"
# fi




# Ensure that the MySQL data directory has the correct ownership to read and write by the mysql user
chown -R mysql:mysql /var/lib/mysql




# Start the MySQL server in the background with networking disabled and using a specific socket file
echo "Starting mysqld in background"
# --skip-networking: Disables TCP/IP connections (only Unix socket connections allowed)
# Why? Security prevents external connections during configuration
# Purpose: Start MariaDB temporarily so we can configure it via socket connection
mysqld --skip-networking --socket=/tmp/mysql.sock &
MYSQL_PID=$!




# Wait until the MySQL server is up and running
echo "Waiting for MySQL server to be ready ..."
DB_ROOT_PASSWORD=$(cat ${DB_ROOT_PASSWORD_FILE})
until mysqladmin --socket=/tmp/mysql.sock ping --silent >/dev/null 2>&1 \
    || mysqladmin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" ping --silent >/dev/null 2>&1
do
    echo "Sleeping..."
    sleep 1;
done

echo "MySQL server is up and running."

MARIADB="mariadb -u root --socket=/tmp/mysql.sock"
# Set root password and remove anonymous users and test database
if mysqladmin --socket=/tmp/mysql.sock ping --silent >/dev/null 2>&1; then
    MARIADB="mariadb --socket=/tmp/mysql.sock -u root -p${DB_ROOT_PASSWORD}" 
fi

echo "Create database and its user and alter root"
DB_PASS=$(cat ${DB_PASSWORD_FILE})

${MARIADB} << EOF

CREATE DATABASE IF NOT EXISTS ${DB_NAME};

CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';

GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

DELETE FROM mysql.user WHERE User='';

FLUSH PRIVILEGES;

EOF

# Stop the temporary MySQL server instance
echo "Stopping temporary mariadb instance that was used for setup and running in background"
kill $MYSQL_PID
wait $MYSQL_PID

# Start the MySQL server normally
echo "Starting mariadb server in foreground"
mysqld