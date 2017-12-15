#!/bin/bash
PATH=/bin:/usr/bin:/sbin:/usr/sbin::/usr/local/bin:/usr/local/sbin;
export PATH

# LAMP目录
DEFAULT_DIR=$(pwd)
LOG_DIR=$(pwd)/log
INIT_DIR=/etc/init.d
MYSQL_DIR=/usr/local/mysql
APACHE_DIR=/usr/local/apache2
PHP_DIR=/usr/local/php5
PCRE_DIR=/usr/local/pcre
GIT_ADDR=https://gitee.com/zd_jaaazzz/clouddisk_geo.git

. lib/check_env.sh
. lib/mysql.sh
. lib/apache.sh
. lib/php.sh
. lib/phpmyadmin.sh
. lib/xunsearch.sh
. lib/pre_start.sh

echo "=================================================================
    Welcome to Onekey CloudDisk installation,created by jaaazzz.
    Version:1.0
    QQ:1003661230
    Since 2017.12.15
=================================================================
    Before executing the script, you have to ensure that the host 
    has been connected to the Internet and the operating system is Ubuntu14.04
==================================================================
Select option for your choice.
    1 install all service
    2 install apache+php
    3 install apache
    4 install mysql
    5 quit"
sleep 0.1
read -p "Please Input 1,2,3,4,5: " SERVER_ID
if [[ $SERVER_ID == 1 ]]; then
     check_env_ins
     mysql_ins
     apache_ins
     php_ins
     phpmyadmin_ins
     xunsearch_ins
     pre_start	
echo "=================================================================
    CloudDisk access address : http://127.0.0.1/clouddisk/index.php
    username : admin
    password : admin
=================================================================
    PhpMyAdmin access address : http://127.0.0.1/phpmyadmin
    username : root
    password : 123456
=================================================================
    Manage apache server :
    /usr/local/apache2/bin/apachectl stop|start|restart|status

    Manage mysql server :
    service mysqld stop|start|restart|status   

    CloudDisk root dir :
    /usr/local/apache2/htdocs/clouddisk
    "
elif [[ $SERVER_ID == 2 ]]; then
     check_env_ins
     apache_ins
     php_ins
elif [[ $SERVER_ID == 3 ]]; then
     check_env_ins
     apache_ins
elif [[ $SERVER_ID == 4 ]]; then
     check_env_ins
     mysql_ins
else
    exit
fi

	

