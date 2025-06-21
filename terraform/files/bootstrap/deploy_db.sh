#!/bin/bash
sudo systemctl stop apt-daily.timer
sudo apt update
sudo apt install -y awscli mariadb-server
sudo bash -c 'echo "[mysqld]" >> /etc/mysql/my.cnf'
sudo bash -c 'echo "bind-address = 0.0.0.0" >> /etc/mysql/my.cnf'
sudo systemctl restart mysql
sudo mysql -e " CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'Pa55WD';
SELECT user FROM mysql.user;
create database flask_db;
grant ALL on flask_db.* to  'admin'@'%';
SHOW DATABASES;"
