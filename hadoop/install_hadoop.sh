#!/bin/bash
# 创建镜像
docker build -t ruteng/ubuntu_1604:hadoop .
# 创建Hadoop集群
./make_contains.sh

