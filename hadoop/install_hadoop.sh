#!/bin/bash

# 参数不可隔断设置,比如要设置第三个参数,则前两个也必须设置
slave_num=${1:-3} # 设置副本数量,默认为3份
block_num=${2:-3} # 设置hdfs块的数量
has_master=${3:-'Y'} # 默认包含,不包含请输入N
share_file=${4:-~/share} # 设置共享文件夹
image_name=${5:-ruteng/ubuntu_1604:hadoop} # 镜像名称
ssh_port=20022

ports=(
	50070	# NameNode http
	50075	# DateNode http
	8480	# journalnode http
	8088	# ResourceManager http
	8042	# NodeManager	http
	19888	# JobHistory Server http
	9000	# NameNode ipc 用于文件系统操作
	50020	# DataNode ipc
	8021	# JobTracker ipc
)

port_str=''
for port in ${ports[@]}
do
	port_str=${port_str}" -p ${port}:${port}"
done

if [ $has_master = 'Y' ]
then
	# 修改config中的文件
	echo "hadoop-master" > ./config/slaves
	# 修改副本数量
	sed -i "" "6s/<value>.*<\/value>/<value>${block_num}<\/value>/g" ./config/hdfs-site.xml
	slave_num=$(($slave_num-1))
else
	echo "" > ./config/slaves
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
	echo "hadoop-slave${i}" >> ./config/slaves
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
docker create --network=hadoop-net --ip=172.20.0.10 -i -t -v ${share_file}:/mnt --name=hadoop-master --hostname=hadoop-master -p ${ssh_port}:22  ${port_str} ${image_name}
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
