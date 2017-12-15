# check the system environment
function check_env_ins { 
    local IN_LOG=$LOG_DIR/check_env_install-$(date +%F).log
    echo "[check_env]check the system environment..."
    sleep 1
    
    # 判断是否为root用户
    if [ $UID != 0 ]; then
        echo "[check_env]You must be root to run the install script."
        exit 0
    fi

    # 判断是否网络连接通畅 
    local timeout=5   
    local target=www.baidu.com  
  
    #获取响应状态码  
    ret_code=`curl -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`  
    if [ "x$ret_code" != "x200" ]; then  
        echo "[check_env]error: network connection is failed"
        exit 0        
    else
        echo "[check_env]Network is active,continue.."
        sleep 1
    fi  

    # 判断能否访问公网
    # echo 8.8.8.8 >> /etc/resolv.conf >> $IN_LOG 2>&1
    # echo "Check your Networking..."
    # NET_ALIVE=$(ping 8.8.8.8 -c 5 |grep 'received'|awk 'BEGIN {FS=","} {print $2}'|awk '{print $1}')
    # if [ $NET_ALIVE == 0 ]; then
    #    echo "Network is not active,please check your network configuration!"
    #    exit 0
    # else
    #    echo "Network is active,continue.."
    #    sleep 1
    # fi

    # 安装开发包(使用默认CENTOS更新源):
    echo "[check_env]Install the Dependency package and dev tools,like vim git rar ..."
    sleep 1
    OS_NAME=$(sed -n '1p' /etc/issue |awk '{print $1}')
    if [ $OS_NAME == 'CentOS' ]; then
        yum -y install lsof wget gcc-c++ ncurses ncurses-devel cmake \
    		    make perl bison openssl openssl-devel gcc* libxml2 \
    		    libxml2-devel curl-devel libjpeg* libpng* freetype* vim git rar unrar bison
    elif [ $OS_NAME == 'Ubuntu' ]; then
        apt-get update
        apt-get install -y  cmake gcc g++ make autoconf libltdl-dev \
					libgd2-xpm-dev libfreetype6 libfreetype6-dev libxml2-dev \
					libjpeg-dev libpng12-dev libcurl4-openssl-dev libssl-dev \
					patch libmcrypt-dev libmhash-dev libncurses5-dev  \
					libreadline-dev bzip2 libcap-dev ntpdate diffutils \
					exim4 iptables unzip sudo vim git rar unrar bison
					
				# 安装chkconfig
				dpkg -i $DEFAULT_DIR/src/chkconfig_11.0-79.1-2_all.deb
				ln -s /usr/lib/insserv/insserv /sbin/insserv >> $IN_LOG 2>&1
    else
        echo "[check_env]unknown system,quit..."
        exit 0
    fi
    
    # 关闭相关服务和SELINUX
    echo "[check_env]Stop useless service..."
    sleep 1 
    
    if [ $OS_NAME == 'CentOS' ]; then
        iptables -F >> $IN_LOG 2>&1
        service iptables save 2>/dev/null
        setenforce 0 >> $IN_LOG 2>&1
        sed -i '/SELINUX/s/enforcing/disabled/g' /etc/selinux/config >> $IN_LOG 2>&1
        sleep 1
    elif [ $OS_NAME == 'Ubuntu' ]; then
        iptables -F >> $IN_LOG 2>&1
        iptables-save >> $IN_LOG 2>&1
    else
        echo "[check_env]unknown system,quit..."
        exit 0
    fi
     
    chkconfig httpd off 2>/dev/null
    chkconfig mysql off 2>/dev/null
    service httpd stop 2>/dev/null
    service mysql stop 2>/dev/null      
    
    # 同步时间
    echo "[check_env]synchronize time..."
    ntpdate tiger.sina.com.cn >> $IN_LOG 2>&1
    hwclock -w
    echo "[check_env]finish check..."
    sleep 1
}
