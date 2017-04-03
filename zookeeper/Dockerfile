#!/bin/bash
# 该配置文件为Hadoop三副本三slave分布式集群安装环境,其他请自行配置
FROM 	ruteng/ubuntu_1604:ssh
MAINTAINER 	柳汝滕 <fingthinking@qq.com>

# 安装Hadoop  如Hadoop版本变化,需要修改该处的版本以及ENV语句
ADD 	zookeeper-3.4.9.tar.gz /opt
ENV TEMP_HOME=/opt/zookeeper-3.4.9

# 配置zoo.cfg
COPY zoo.cfg hosts.tmp ${TEMP_HOME}/conf/

# 为了设置ssh设置环境变量并且创建文件夹
RUN 	echo "export PATH=${PATH}:${TEMP_HOME}/bin" >> /etc/profile && \
    	mkdir -p /opt/zk_data && \
	mkdir -p /opt/zk_log && \
	mv ${TEMP_HOME}/conf/hosts.tmp /etc/hosts.bak
CMD 	["sh","-c","cat /etc/hosts.bak > /etc/hosts; /bin/bash"]
