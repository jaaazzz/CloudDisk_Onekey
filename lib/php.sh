# php install function
function php_ins {
 
    local IN_LOG=$LOG_DIR/php_install-$(date +%F).log
    echo "[php]Install the PHP module for apache..."
    sleep 1
    
    #fix bug freetype.h can not found
    ln -sf /usr/include/freetype2 /usr/include/freetype2/freetype
 
    cd $DEFAULT_DIR/src
    tar -jxvf php-5.5.9.tar.bz2 >> $IN_LOG 2>&1 
    cd php-5.5.9
    # 此处编译安装了我们项目经常用到的PHP模块,如有其它需要可以自定义添加.
    ./configure --prefix=$PHP_DIR --with-apxs2=$APACHE_DIR/bin/apxs \
     --with-libxml-dir=/usr/local/lib --with-zlib-dir=/usr/local/lib \
     --with-mysql=$MYSQL_DIR --with-mysqli=$MYSQL_DIR/bin/mysql_config \
     --with-gd --enable-soap --enable-sockets --enable-xml --enable-mbstring \
     --with-png-dir=/usr/local --with-jpeg-dir=/usr/local --with-curl=/usr/lib \
     --with-freetype-dir=/usr/include/freetype2/freetype/ --enable-bcmath \
     --enable-calendar --enable-zip --enable-maintainer-zts \
     --with-pdo-mysql >> $IN_LOG 2>&1 
    
    if [[ $? != 0 ]]; then
    	 echo "[php]error in the compilation,stop.."
    	 exit 0
		fi
    echo "[php]make..."    
    make >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[php]error in the compilation,stop.."
    	 exit 0
		fi
    echo "[php]make install..."		
    make install >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[php]error in the compilation,stop.."
    	 exit 0
    else
        echo "[php]compilation finish..."
		fi
    
    # 判断目录是否创建:
    if [ ! -d $PHP_DIR ];then
        echo "[php]$PHP_DIR is not exist,stop..."
        exit 0
    fi
    
    # PHP配置项：
    echo "[php]configuration after the installation...."
    sleep 1
    cp php.ini-development $PHP_DIR/lib/php.ini
    echo "AddType application/x-httpd-php .php" >> $APACHE_DIR/conf/httpd.conf
    sed -i '/DirectoryIndex index.html/s/$/ &index.php/g' $APACHE_DIR/conf/httpd.conf
    # 隐藏PHP版本信息：
    # echo "expose_php = Off" >> $PHP_DIR/lib/php.ini
    # 关闭警告及错误信息,爆路径:
    echo "display_errors = Off" >> $PHP_DIR/lib/php.ini
    # 调整时区,防止phpinfo()函数报错.
    echo "date.timezone =PRC" >> $PHP_DIR/lib/php.ini
    # 开启php错误日志并设置路径.
    echo "log_errors = On" >> $PHP_DIR/lib/php.ini
    echo "error_log = $APACHE_DIR/logs/php_error.log"  >> $PHP_DIR/lib/php.ini
    
    cd $DEFAULT_DIR
    cp conf/info.php $APACHE_DIR/htdocs >> $IN_LOG 2>&1
    
    # 重启apache:
    echo "[php]restart apache to load the php module..."
    #$APACHE_DIR/bin/apachectl stop >> $IN_LOG 2>&1
    $APACHE_DIR/bin/apachectl restart >> $IN_LOG 2>&1
    # 判断PHP是否加载:
    PHP_LOAD=$(curl --head http://localhost/info.php |grep PHP |wc -l)
    if [ $PHP_LOAD == 0 ]; then
       echo "[php]PHP does not load,please check your configure!"
       exit 0
    else
       echo "[php]Congratulation,PHP module has been installed correctly!"
       sleep 1
    fi
}
