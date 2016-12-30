#!/bin/bash

# 参数说明, 1:副本数量;2,是否包含master,默认包含Y;3.共享文件夹
# 参数不可隔断设置,比如要设置第三个参数,则前两个也必须设置
slave_num=${1:-3} # 设置副本数量,默认为3份
has_master=${2:-'Y'} # 默认包含,不包含请输入N
share_file=${3:-~/share} # 设置共享文件夹
image_name=${4:-ruteng/ubuntu_1604:hadoop} # 镜像名称

if [ $has_master = 'Y' ]
then
	slave_num=$(($slave_num-1))
	# 修改config中的文件
	echo "hadoop-master" > ./config/slaves
	# 修改副本数量
	sed -i '6s/<value>.<\/value>/<value>4<\/value>/g' ./config/hdfs-site.xml
fi

# 创建网络
hadoop_net=`docker network ls | grep 'hadoop-net'`
if [ $? -eq 1 ]; # 如果之前不存在hadoop-net网络 
then
	echo "创建hadoop-net网络"
        docker network create --subnet=172.20.0.0/16 hadoop-net # 创建hadoop-net网络
fi

# 将ip写入到hosts文件
echo "创建hosts文件"
echo "172.20.0.10 hadoop-master" > hosts.1
for i in $(seq 1 ${slave_num}) # 创建hosts文件
do
        echo "172.20.0.1${i} hadoop-slave${i}" >> hosts.1
done
# 将hosts文件追加到宿主机
sudo sed -i -e '/hadoop/d' /etc/hosts
sudo sh -c "cat hosts.1 >> /etc/hosts"
cat hosts.tpl > ./config/hosts && cat hosts.1 >> ./config/hosts
rm -f hosts.1

# 创建本机的ssh
if [ ! -e ~/.ssh/id_rsa.pub ]
then
        ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
fi
cat ~/.ssh/id_rsa.pub > ./authorized_keys && cat ./authorized_keys.tpl >> ./authorized_keys

# 写入本地ssh授权
sed -i -e "/[hadoop|${USER}]/d" ~/.ssh/authorized_keys
cat ./authorized_keys >> ~/.ssh/authorized_keys

# 构建镜像
hadoop_img=`docker images -a | grep -e 'ruteng.*hadoop'`
if [ $? -eq 1 ]
then
	echo "创建镜像${image_name}"
	docker build -t ${image_name} ./ # 创建镜像
fi

# 删除之前创建的容器
source delete_contains.sh

# 创建新的容器
echo "创建容器hadoop-master"
docker create --network=hadoop-net --ip=172.20.0.10 -i -t -v ${share_file}:/mnt --name=hadoop-master --hostname=hadoop-master ${image_name}
docker cp ./authorized_keys hadoop-master:/root/.ssh/authorized_keys
docker start hadoop-master

for i in $(seq 1 ${slave_num}) # 创建容器
do
        echo "创建容器hadoop-slave"$i
        docker create --network=hadoop-net --ip=172.20.0.1${i} -i -t -v ${share_file}:/mnt --name=hadoop-slave${i} --hostname=hadoop-slave${i} ${image_name}
        docker cp ./authorized_keys hadoop-slave${i}:/root/.ssh/authorized_keys
        docker start hadoop-slave${i}
done

# 删除临时文件
rm -rf ./authorized_keys ./config/hosts
