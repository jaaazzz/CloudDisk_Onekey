# phpmyadmin install function
function phpmyadmin_ins {

	local IN_LOG=$LOG_DIR/phpmyadmin_install-$(date +%F).log
	echo "[phpmyadmin]Install phpmyadmin..."
	sleep 1

    echo "[phpmyadmin]extract phpmyadmin package"
    cd $DEFAULT_DIR/src
    tar -zxvf phpmyadmin.tar.gz  

    # 判断根目录是否创建:
    if [ ! -d $APACHE_DIR/htdocs ];then
        echo "[phpmyadmin]$APACHE_DIR/htdocs is not exist,stop..."
        exit 0
    fi

    mv phpmyadmin $APACHE_DIR/htdocs/  
    chmod 755 -R $APACHE_DIR/htdocs/  
    chown www:www -R $APACHE_DIR/htdocs/  

    # 判断phpmyadmin网络连接通畅 
    local timeout=5   
    local target=127.0.0.1/phpmyadmin  
  
    #获取响应状态码  
    ret_code=`curl -L -I -s --connect-timeout $timeout $target -w %{http_code} | tail -n1`  
    if [ "x$ret_code" = "x200" ]; then  
        echo "[phpmyadmin]Congratulation,phpmyadmin module has been installed correctly!"  
        sleep 1     
    else
        echo "[phpmyadmin]phpmyadmin does not installed correctly,please check your configure!"
        exit 0     
    fi 

}

