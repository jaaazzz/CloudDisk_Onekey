# mysql install function
function mysql_ins {
    local IN_LOG=$LOG_DIR/mysql_install-$(date +%F).log
    echo "[mysql]Install the MySQL service..."
    sleep 1
    
    # 安装前的初始配置工作：
    echo "[mysql]The initial configuration before installation..."
    sleep 1
    mkdir -p $MYSQL_DIR >> $IN_LOG 2>&1
    useradd -d $MYSQL_DIR mysql >> $IN_LOG 2>&1
    mkdir -p $MYSQL_DIR/data >> $IN_LOG 2>&1      
    mkdir -p $MYSQL_DIR/log >> $IN_LOG 2>&1          
    chown -R mysql:mysql $MYSQL_DIR/data/ >> $IN_LOG 2>&1
    chown -R mysql:mysql $MYSQL_DIR/log/ >> $IN_LOG 2>&1
    chmod 750 $MYSQL_DIR/data >> $IN_LOG 2>&1     
    chmod 750 $MYSQL_DIR/log >> $IN_LOG 2>&1      
    
    # 解包编译安装:
    echo "[mysql]make install the MySQL package..."
    sleep 1
    cd $DEFAULT_DIR
    cd src/
    tar -zxvf mysql-5.6.13.tar.gz >> $IN_LOG 2>&1  
    cd mysql-5.6.13 
    sed -i "/ADD_SUBDIRECTORY(sql\/share)/d" CMakeLists.txt && 
    sed -i "s/ADD_SUBDIRECTORY(libmysql)/&\\nADD_SUBDIRECTORY(sql\/share)/" CMakeLists.txt && 
    sed -i "s@data/test@\${INSTALL_MYSQLSHAREDIR}@g" sql/CMakeLists.txt && 
    sed -i "s@data/mysql@\${INSTALL_MYSQLTESTDIR}@g" sql/CMakeLists.txt && 
    sed -i "s/srv_buf_size/srv_sort_buf_size/" storage/innobase/row/row0log.cc && 
    cmake -DCMAKE_INSTALL_PREFIX=$MYSQL_DIR \
    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
    -DDEFAULT_CHARSET=gbk \
    -DDEFAULT_COLLATION=gbk_chinese_ci \
    -DEXTRA_CHARSETS=all \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MEMORY_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_READLINE=1 \
    -DENABLED_LOCAL_INFILE=1 \
    -DMYSQL_DATADIR=$MYSQL_DIR/data \
    -DMYSQL_USER=mysql \
    -DMYSQL_TCP_PORT=3306 \
    -DSYSCONFDIR=/etc \
    -DWITH_SSL=yes >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[mysql]error in the compilation,stop.."
    	 exit 0
		fi

    echo "[mysql]make..." 
    make >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[mysql]error in the compilation,stop.."
    	 exit 0
		fi
    echo "[mysql]make install..."		
    make install >> $IN_LOG 2>&1
    
    if [[ $? != 0 ]]; then
    	 echo "[mysql]error in the compilation,stop.."
    	 exit 0
    else
       echo "[mysql]compilation finish..."
		fi
        
    # 判断目录是否创建:
    if [ ! -d $MYSQL_DIR ];then
        echo "[mysql]$MYSQL_DIR is not exist,stop..."
        exit 0
    fi
    
    # mysql配置项：
    echo "[mysql]configuration after the installation...."
    sleep 1
    [ -e /etc/my.cnf ] && rm -rf /etc/my.cnf >> $IN_LOG 2>&1
    cd $DEFAULT_DIR
    cp conf/my.cnf /etc/my.cnf >> $IN_LOG 2>&1
    
    if [ -s /etc/mysql/my.cnf ]; then
      echo "[mysql]/etc/mysql/my.cnf found ,rename it..."  
      mv /etc/mysql/my.cnf /etc/mysql.cnfbak
    fi
  
    # 将mysql的库文件路径加入系统的库文件搜索路径中
    ln -sf $MYSQL_DIR/lib/mysql /usr/lib/mysql >> $IN_LOG 2>&1
    
    # 输出mysql的头文件到系统头文件
    ln -sf $MYSQL_DIR/include/mysql /usr/include/mysql >> $IN_LOG 2>&1
    
    # 进入安装路径,初始化配置脚本
    echo "[mysql]Initialize the configuration of the MySQL..."
    sleep 1
    cd $MYSQL_DIR
    scripts/mysql_install_db --user=mysql --datadir=$MYSQL_DIR/data >> $IN_LOG 2>&1
    
    # 复制mysql启动脚本到系统服务目录
    [ -e $INIT_DIR/mysqld ] && mv $INIT_DIR/mysqld $INIT_DIR/mysqld.old >> $IN_LOG 2>&1
    cp $MYSQL_DIR/support-files/mysql.server $INIT_DIR/mysqld >> $IN_LOG 2>&1
    
    # 系统启动项相关配置
    chkconfig --add mysqld  >> $IN_LOG 2>&1
    chkconfig --level 35 mysqld on >> $IN_LOG 2>&1
    
    # 启动mysql
    service mysqld start >> $IN_LOG 2>&1 
    
    # 配置权限
    echo "[mysql]Configure MySQL authority..."
    sleep 1
    $MYSQL_DIR/bin/mysqladmin -u root password 123456 >> $IN_LOG 2>&1
    #给root用户非本地链接所有权限,并改密码和赋予其给其他人下发权限.
    $MYSQL_DIR/bin/mysql -u root -p123456 -e "grant all privileges on *.* to root@'%' identified by '123456' with grant option;" >> $IN_LOG 2>&1
    $MYSQL_DIR/bin/mysql -u root -p123456 -e "grant all privileges on *.* to root@'localhost' identified by '123456' with grant option;" >> $IN_LOG 2>&1
    
    # 设置环境变量
    echo 'PATH=$PATH:/usr/local/mysql/bin;export PATH' >> /etc/profile
    source /etc/profile >> $IN_LOG 2>&1
    
    # 判断服务是否启动
    PORT_3306=$(lsof -i:3306|wc -l)
    if [ $PORT_3306 == 0 ]; then
       echo "[mysql]MySQL service is not active,please check your configure!"
       exit 0
    else
       echo "[mysql]Congratulation,MySQL service has been installed correctly!"
       sleep 1
    fi
    
    
}
