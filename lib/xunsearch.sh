# xunsearch install function
function xunsearch_ins {

	local IN_LOG=$LOG_DIR/xunsearch_install-$(date +%F).log
    echo "[xunsearch]Install xunsearch..."
    sleep 1
    
    #update C++ compiler
    echo '[xunsearch]update C++ compiler...'
    sleep 1
    apt-get install build-essential -y  >> $IN_LOG 2>&1
    gcc -v  >> $IN_LOG 2>&1
    make -v  >> $IN_LOG 2>&1

    if [[ $? != 0 ]]; then
        echo "[xunsearch]error in the compilation,stop.."
        exit 0
    else
        echo "[xunsearch]C++ compiler compilation finish..."
        sleep 1
    fi
    
    #install zlib
    echo "[xunsearch]Install zlib..."
    sleep 1

    #extract and make install
    echo "[xunsearch]extract and make install zlib..."
    cd $DEFAULT_DIR/src
    tar -zxvf zlib-1.2.11.tar.gz  >> $IN_LOG 2>&1
    cd zlib-1.2.11
    ./configure  >> $IN_LOG 2>&1
    make  >> $IN_LOG 2>&1
    make install  >> $IN_LOG 2>&1
    
    echo "[xunsearch]extract xunsearch package"
    cd $DEFAULT_DIR/src
    tar -xjf xunsearch-full-latest.tar.bz2  >> $IN_LOG 2>&1
    mv xunsearch-full-1* xunsearch
    cd xunsearch/
    sh setup.sh --prefix=/usr/local/xunsearch  >> $IN_LOG 2>&1

    if [[ $? != 0 ]]; then
        echo "[xunsearch]error in the compilation,stop.."
        exit 0
    else
        echo "[xunsearch]compilation finish..."
        sleep 1
    fi

    cd /usr/local/xunsearch ; bin/xs-ctl.sh restart  >> $IN_LOG 2>&1

    # 判断服务是否启动
    PORT_8383=$(lsof -i:8383|wc -l)
    PORT_8384=$(lsof -i:8384|wc -l)
    if [ $PORT_8383 == 0 || $PORT_8384 == 0]; then
       echo "[xunsearch]Xunsearch service is not active,please check your configure!"
       exit 0
    else
       echo "[xunsearch]Congratulation,Xunsearch service has been installed correctly!"
       sleep 1
    fi
}

