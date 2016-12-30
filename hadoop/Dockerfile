#!/bin/bash
# 该配置文件为Hadoop三副本三slave分布式集群安装环境,其他请自行配置
FROM 	ruteng/ubuntu_1604:ssh
MAINTAINER 	柳汝滕 <fingthinking@qq.com>

# 安装Hadoop  如Hadoop版本变化,需要修改该处的版本以及ENV语句
ADD 	hadoop-2.7.3.tar.gz /opt
ENV TEMP_HOME=/opt/hadoop-2.7.3

# 配置分布式集群安装环境
COPY 	config/* ${TEMP_HOME}/etc/hadoop/

# 为了设置ssh设置环境变量并且创建文件夹
RUN 	echo "export HADOOP_HOME=${TEMP_HOME}\nexport PATH=\${PATH}:\${HADOOP_HOME}/bin:\${HADOOP_HOME}/sbin" >> /etc/profile && \
    	mkdir -p /opt/hdfs/name && \
	mkdir -p /opt/hdfs/data && \
	mkdir -p /opt/hdfs/tmp && \
	mv ${TEMP_HOME}/etc/hadoop/hosts /etc/hosts.bak
CMD 	["sh","-c","cat /etc/hosts.bak > /etc/hosts; /bin/bash"]
