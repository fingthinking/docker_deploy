#!/bin/bash
# 创建多个容器,用于安装hadoop, 以下三个为默认设置,可以作为参数传入进来
slave_num=${1:-3} # slave数量,默认为3
image=${2:-ruteng/ubuntu_1604:hadoop} # 原始镜像
share_file=${3:-~/share}


# 创建网络
hadoop_net=`docker network ls | grep 'hadoop-net'`
    # 判断语句中括号必须加空格
if [ $? -eq 1 ]; # 如果之前不存在hadoop-net网络 
then
	docker network create --subnet=172.20.0.0/16 hadoop-net # 创建hadoop-net网络
fi

# 删除之前创建的容器
contains=`docker ps -a | awk '{print $NF}' | grep "hadoop"`
if [ $? -eq 0 ];	# 如果执行成功
then 
	docker rm -f ${contains}
fi

# 创建本机的ssh
if [ ! -e ~/.ssh/id_rsa.pub ]
then
        ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
fi
cat ~/.ssh/id_rsa.pub > ./.authorized_keys && cat ./authorized_keys.tpl >> ./.authorized_keys

# 写入本地ssh授权
cat ./.authorized_keys >> ~/.ssh/authorized_keys

# 将ip写入到hosts文件
echo "172.20.0.10 hadoop-master" >> hosts.1
for i in $(seq 1 ${slave_num}): # 创建hosts文件
do
	echo "172.20.0.1${i} hadoop-slave${i}" >> hosts.1
done
# 将hosts文件追加到宿主机
sed -i '/hadoop/d' /etc/hosts
cat hosts.1 >> /etc/hosts
cat hosts.tpl >> hosts && cat hosts.1 >> hosts
rm -f hosts.1
# 创建新的容器
echo "创建容器hadoop-master"
docker create --network=hadoop-net --ip=172.20.0.10 -i -t -v ${share_file}:/mnt --name=hadoop-master --hostname=hadoop-master ${image} 
docker start hadoop-master
docker cp ./.authorized_keys hadoop-master:root/.ssh/authorized_keys # 写入远程
docker cp hosts hadoop-master:etc/hosts


for i in $(seq 1 ${slave_num}); # 创建容器
do
	echo "创建容器hadoop-slave"$i
	docker create --network=hadoop-net --ip=172.20.0.1${i} -i -t -v ${share_file}:/mnt --name=hadoop-slave${i} --hostname=hadoop-slave${i} ${image} 
	docker start hadoop-slave${i}
	docker cp ./.authorized_keys hadoop-slave${i}:root/.ssh/authorized_keys # 写入远程
	docker cp hosts hadoop-slave${i}:etc/hosts
done

# 删除临时文件
rm -f ./.authorized_keys
rm -f ./hosts
