#!/bin/bash
# 删除之前创建的容器
contains=`docker ps -a | awk '{print $NF}' | grep "hadoop"`
if [ $? -eq 0 ];        # 如果执行成功
then
        docker rm -f ${contains}
fi

