# php install function
function pre_start { 
    local IN_LOG=$LOG_DIR/php_install-$(date +%F).log
    echo "[pre_start]prepare to start clouddisk..."
    sleep 1
    
    #克隆云盘源码
    echo "[pre_start]git clone clouddisk origin code..."
    sleep 1
    cd $APACHE_DIR/htdocs
    git clone https://jaaazzz:y1002.@gitee.com/zd_jaaazzz/clouddisk_geo.git

    if [[ $? != 0 ]]; then
        echo "[pre_start]error : git clone failed,stop.."
        exit 0
    else
        echo "[pre_start]git clone finish..."
        sleep 1
    fi

    mv clouddisk_geo clouddisk
    mv clouddisk/data-example clouddisk/data
    mv clouddisk/config/config_example.php clouddisk/config/config.php
    chmod -R 777 clouddisk

    #load sql file
    echo "[pre_start]load sql file..."
    mysql -uroot -p123456  < clouddisk/clouddisk.sql

    #restart apache server
    echo "[pre_start]restart apache server..."
    $APACHE_DIR/bin/apachectl stop >> $IN_LOG 2>&1
    $APACHE_DIR/bin/apachectl start >> $IN_LOG 2>&1

    # 判断clouddisk是否安装成功
    local timeout=5   
    local target=127.0.0.1/clouddisk  
  
    #获取响应状态码  
    ret_code=`curl -L -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`  
    if [ "x$ret_code" = "x200" ]; then  
        echo "[pre_start]Congratulation,clouddisk has been installed correctly!"       
    else
        echo "[pre_start]clouddisk does not installed correctly,please check your configure!"
        exit 0     
    fi 
}

