#!/bin/bash

read -p "确定是ubuntu18.04系统吗?如果不是ubuntu18.04,可能影响系统正常运行[y/n]:" sure
case $sure in
y|Y|Yes|yes|YES)
       echo "";;
n|N|NO|no)
       exit 1;;
*)
       exit 1;;
esac

IN_LOG=install_webdav-$(date +%F).log

#自动更换ubuntu1804 163源
echo ">>>>>>备份原有源"
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo ">>>>>>加入ubuntu1804 163更新源"
echo deb http://mirrors.163.com/ubuntu/ bionic main restricted universe multiverse > /etc/apt/sources.list
echo deb http://mirrors.163.com/ubuntu/ bionic-security main restricted universe multiverse >> /etc/apt/sources.list
echo deb http://mirrors.163.com/ubuntu/ bionic-updates main restricted universe multiverse >> /etc/apt/sources.list
echo deb http://mirrors.163.com/ubuntu/ bionic-proposed main restricted universe multiverse >> /etc/apt/sources.list
echo deb http://mirrors.163.com/ubuntu/ bionic-backports main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://mirrors.163.com/ubuntu/ bionic main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://mirrors.163.com/ubuntu/ bionic-security main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://mirrors.163.com/ubuntu/ bionic-updates main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://mirrors.163.com/ubuntu/ bionic-proposed main restricted universe multiverse >> /etc/apt/sources.list
echo deb-src http://mirrors.163.com/ubuntu/ bionic-backports main restricted universe multiverse >> /etc/apt/sources.list
echo ">>>>>>执行apt update"
apt update >> $IN_LOG 2>&1

if [ $? -eq 0 ];then
	echo ">>>>>>ubuntu1804 163源更换成功"
else
	echo ">>>>>>ubuntu1804 163源更换失败"
fi

#安装并启动mysql
apt-get install mysql-server mysql-client -y >> $IN_LOG 2>&1
if [ $? -eq 0 ];then
	echo ">>>>>>安装mysql成功"
else
	echo ">>>>>>安装mysql失败"
fi
service mysql start >> $IN_LOG 2>&1
if [ $? -eq 0 ];then
	echo ">>>>>>启动mysql服务成功"
else
	echo ">>>>>>启动mysql服务失败"
fi

#安装apache2
apt-get install apache2 -y >> $IN_LOG 2>&1
if [ $? -eq 0 ];then
	echo ">>>>>>安装apache2成功"
else
	echo ">>>>>>安装apache2失败"
fi


#安装php
apt install php libapache2-mod-php php-mysql php-curl php-gd php-mbstring php-xml -y >> $IN_LOG 2>&1
if [ $? -eq 0 ];then
	echo ">>>>>>安装php7成功"
else
	echo ">>>>>>安装php7失败"
fi


#重启服务器apache2
service apache2 restart >> $IN_LOG 2>&1
if [ $? -eq 0 ];then
service_result="重启服务器apache2成功"
echo ">>>>>>重启服务器apache2成功"
else
service_result="重启服务器apache2失败"
echo ">>>>>>重启服务器apache2失败"
fi

#安装webdav server端
#
echo ">>>>>>克隆webdav源码"
sleep 1
cd /var/www/html
read -p "输入代码仓库账号:" username
read -p "输入代码仓库密码:" password

echo "git clone https://$username:$password@gitee.com/shuwang1992/webDav.git"
git clone https://$username:$password@gitee.com/shuwang1992/webDav.git

if [[ $? != 0 ]]; then
    echo ">>>>>>克隆webdav源码失败"
    exit 0
else
    echo ">>>>>>克隆webdav源码成功"
    sleep 1
fi
echo ">>>>>>环境搭配任务已经处理完毕！<<<<<<"
