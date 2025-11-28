#!/bin/bash
set -eu

echo "WordPress entrypoint script"

mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html

cd /var/www/html

if [ ! -f wp-settings.php ]; then
    echo ">>>>>>>>>>>>>>Downloading WordPress..."
    wp core download --allow-root
else
    echo ">>>>>>>>>>>>>>WordPress Already Downloaded!"
fi

if [ ! -f wp-config.php ]; then
	echo ">>>>>>>>>>>>>>Copying wp-config.php..."
	mv /tmp/wp-config.php /var/www/html/wp-config.php
else
	echo ">>>>>>>>>>>>>>wp-config.php Present"
fi

chown -R www-data:www-data /var/www/html/*

echo ">>>>>>>>>>>>>>Waiting for mariadb..."
DB_PASS=$(cat ${DB_PASSWORD_FILE})
while ! mysqladmin ping -h "${DB_HOST}" -u "${DB_USER}" -p"${DB_PASS}" --silent; do
	echo ">>>>>>>>>>>>>>Database is unavailable - sleeping..."
	sleep 2
done

WP_ADMIN_PASS=$(cat ${WP_ADMIN_PASSWORD_FILE})
if ! wp core is-installed --allow-root; then
	echo ">>>>>>>>>>>>>>Installing Wordpress..."

	wp core install \
        --url="https://merrahal.42.fr" \
        --title="${TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email --allow-root

else
	echo ">>>>>>>>>>>>>>Wordpress Already Installed!"
fi

WP_USER_PASS=$(cat ${WP_USER_PASSWORD_FILE})
if ! wp user get "${WP_USER}" --field=ID --allow-root > /dev/null 2>&1; then
	echo ">>>>>>>>>>>>>>Create new user..."
	wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
		--role=${WP_ROLE} --user_pass="${WP_USER_PASS}" --allow-root
else
	echo ">>>>>>>>>>>>>>User already Created!"
fi

echo ">>>>>>>>>>>>>>Setting proper permissions..."
find /var/www/html -type d -exec chmod 775 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo ">>>>>>>>>>>>>>Starting php-fpm8.2..."
exec php-fpm8.2 -F
