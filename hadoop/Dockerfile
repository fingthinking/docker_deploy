#!/bin/bash
# 该配置文件为Hadoop三副本三slave分布式集群安装环境,其他请自行配置
FROM ruteng/ubuntu_1604:ssh
MAINTAINER 柳汝滕 <fingthinking@qq.com>

# 安装Hadoop
ADD hadoop-2.7.3.tar.gz /opt
# 设置环境变量
ENV HADOOP_HOME=/opt/hadoop-2.7.3
ENV PATH=${PATH}:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin
# 配置分布式集群安装环境 默认是三个副本,三个slave
COPY config/* /opt/hadoop/etc/hadoop/
# 创建文件夹
RUN mkdir -p /opt/hdfs/name && mkdir -p /opt/hdfs/data && mkdir -p /opt/hdfs/tmp
