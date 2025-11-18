#!/bin/bash

set -eu

echo ">>>>Creating empty dir"
mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty

echo ">>>>Creating ${FTP_USER}"
useradd -m ${FTP_USER}
FTP_PASS=$(cat ${FTP_USER_PASSWORD_FILE})
echo "${FTP_USER}:${FTP_PASS}" | chpasswd
echo ">>>>Adding ${FTP_USER} to www-data group"
usermod -a -G www-data ${FTP_USER}

echo "removing write permission for /home/${FTP_USER}"
chmod a-w /home/${FTP_USER}
mkdir -p /home/${FTP_USER}/wordpress

vsftpd /etc/vsftpd.conf
