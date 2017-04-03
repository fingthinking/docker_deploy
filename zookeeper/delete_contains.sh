#!/bin/bash
# 删除之前创建的容器
contains=`docker ps -a | awk '{print $NF}' | grep "zk_server"`
if [ $? -eq 0 ];        # 如果执行成功
then
	echo $contains
        docker rm -f ${contains}
fi

