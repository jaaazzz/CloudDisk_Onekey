# apache install function
function apache_ins {   
    local IN_LOG=$LOG_DIR/apache_install-$(date +%F).log
    echo "[apache]Install the Apache service..."
    sleep 1
    
    # pcre依赖包安装
    echo "[apache]install the dependency pcre package..."
    sleep 1
    cd $DEFAULT_DIR/src
    tar -xzvf pcre-8.32.tar.gz >> $IN_LOG 2>&1
    cd pcre-8.32
    ./configure --prefix=$PCRE_DIR >> $IN_LOG 2>&1
    make >> $IN_LOG 2>&1
    make install >> $IN_LOG 2>&1
    
    # apache安装
    echo "[apache]install apache package..."
    sleep 1
    # 注:httpd-2.4.3-deps.tar.bz2已集成APR，安装apache前检查pcre是否安装成功.
    cd $DEFAULT_DIR/src
    tar jxvf httpd-2.4.4.tar.bz2 >> $IN_LOG 2>&1
    tar jxvf httpd-2.4.3-deps.tar.bz2 >> $IN_LOG 2>&1
    cp -rf httpd-2.4.3/* httpd-2.4.4
    cd httpd-2.4.4
     ./configure --prefix=$APACHE_DIR --enable-so --enable-rewrite \
         -enable-ssl=static -with-ssl=/usr/local/ssl -enable-mods-shared=all \
         --with-pcre=$PCRE_DIR/bin/pcre-config >> $IN_LOG 2>&1
         
   	if [[ $? != 0 ]]; then
    	 echo "[apache]error in the compilation,stop.."
    	 exit 0
		fi
    
    make >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[apache]error in the compilation,stop.."
    	 exit 0
		fi
		
    make install >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[apache]error in the compilation,stop.."
    	 exit 0
    else
        echo "[apache]compilation finish..."
		fi
    
    # 判断目录是否创建:
    if [ ! -d $APACHE_DIR ];then
        echo "[apache]$APACHE_DIR is not exist,stop..."
        exit 0
    fi
    
    # apache配置项：
    echo "[apache]configuration after the installation...."
    sleep 1
    # 防止apache启动报错.
    echo "ServerName localhost:80" >> $APACHE_DIR/conf/httpd.conf
    # 设置开机启动
    # 注:ubuntu添加启动项需插入到 exit 0 前
    if [ $OS_NAME == 'CentOS' ]; then
        echo "$APACHE_DIR/bin/apachectl start" >> /etc/rc.local
    elif [ $OS_NAME == 'Ubuntu' ]; then
        sed -i "/^exit 0/ i\\$APACHE_DIR\/bin\/apachectl start" /etc/rc.local
    else
        echo "unknown system,quit..."
        exit 0
    fi    
    
    # 启动apache
    echo "[apache]start apache httpd service..."
    sleep 1
    $APACHE_DIR/bin/apachectl start  >> $IN_LOG 2>&1 
    
    # 设置环境变量
    echo 'PATH=$PATH:/usr/local/apache2/bin;export PATH' >> /etc/profile
    source /etc/profile >> $IN_LOG 2>&1
    
    # 判断服务是否启动
    PORT_80=$(lsof -i:80|wc -l)
    if [ $PORT_80 == 0 ]; then
       echo "[apache]Apache httpd service is not active,please check your configure!"
       exit 0
    else
       echo "[apache]Congratulation,Apache httpd service has been installed correctly!"
    fi
} 





