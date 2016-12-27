#!/bin/bash
# 创建多个容器,用于安装hadoop
# 创建网络
hadoop_net=`docker network ls | grep 'hadoop-net'`
    # 判断语句中括号必须加空格
if [ $? -eq 1 ]; # 如果之前不存在hadoop-net网络 
then
	docker network create --subnet=172.20.0.0/16 hadoop-net # 创建hadoop-net网络
fi

# 删除之前创建的
contains=`docker ps -a | awk '{print $NF}' | grep "hadoop"`
if [ $? -eq 0 ];	# 如果执行成功
then 
	docker rm -f ${contains}
fi


# 创建新的
slave_num=2 # slave数量
image=ruteng/ubuntu_16_04:ssh # 原始镜像
share_file=/home/ruteng/share

echo "创建容器hadoop-master"
docker create --network=hadoop-net --ip=172.20.0.10 -i -t -v ${share_file}:/mnt --name=hadoop-master --hostname=hadoop-master ${image} 
docker start hadoop-master
for i in $(seq 1 ${slave_num});
do
	echo "创建容器hadoop-slave"$i
	docker create --network=hadoop-net --ip=172.20.0.1${i} -i -t -v ${share_file}:/mnt --name=hadoop-slave${i} --hostname=hadoop-slave${i} ${image} 
	docker start hadoop-slave${i}
done
