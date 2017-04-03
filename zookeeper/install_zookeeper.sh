#!/bin/bash
share_file=${1:-~/share} # 设置共享文件夹
zk_num=${2:-3} # 设置zk集群数量 
image_name=${3:-ruteng/ubuntu_1604:zookeeper} # 镜像名称
ssh_port=20022
zk_net='172.30.0.0'
zk_prefix=${zk_net%'0'}
zk_net_name='zookeeper-net'
zk_server='zk_server'

zk_client_port=2181	# zookeeper Client port
zk_data_port=2888	# zookeeper Data transport
zk_leader_port=3888	# zookeeper Leader 选举

ports=(${zk_client_port} ${zk_data_port} ${zk_leader_port})

# 开放端口号列表
port_str=''
for port in ${ports[@]}
do
	port_str=${port_str}" -p ${port}:${port}"
done

# 创建网络
zookeeper_net=`docker network ls | grep 'zookeeper-net'`
if [ $? -eq 1 ]; # 如果之前不存在zookeeper-net网络 
then
	echo "创建zookeeper-net网络"
        docker network create --subnet=${zk_net}/16 ${zk_net_name} # 创建zookeeper-net网络
fi

# 将ip写入到hosts文件
echo "创建hosts文件"
cp zoo.cfg.tpl zoo.cfg
for i in $(seq 1 ${zk_num}) # 创建hosts文件
do
	lst=`printf "%.2d" $i`
        echo "${zk_prefix}1${lst} ${zk_server}${i}" >> hosts.1
	# 替换zoo.cfg
	sed -i"" -e "\$a server.${i}=${zk_prefix}1${lst}:${zk_data_port}:${zk_leader_port}" zoo.cfg
done

# 将hosts文件追加到宿主机
sudo sed -i"" -e "/${zk_server}/d" /etc/hosts	# 删除和hadoop相关的host配置
sudo sh -c "cat hosts.1 >> /etc/hosts"
cat hosts.tpl > ./hosts.tmp && cat hosts.1 >> ./hosts.tmp
rm -f hosts.1

# 创建本机的ssh
if [ ! -e ~/.ssh/id_rsa.pub ]
then
        ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
fi
cat ~/.ssh/id_rsa.pub > ./authorized_keys && cat ./authorized_keys.tpl >> ./authorized_keys

# 写入本地ssh授权
sed -i -e "/[docker|${USER}]/d" ~/.ssh/authorized_keys
cat ./authorized_keys >> ~/.ssh/authorized_keys

# 构建镜像
zk_img=`docker images -a | grep -e "${image_name}"`
if [ $? -eq 1 ]
then
	echo "创建镜像${image_name}"
	docker build -t ${image_name} ./ # 创建镜像
fi

# 删除之前创建的容器
sh delete_contains.sh

# 创建新的容器
for i in $(seq 1 ${zk_num}) # 创建容器
do
        echo "创建容器${zk_server}${i}"
	lst=`printf "%.2d" $i`
        docker create --network=${zk_net_name} --ip=${zk_prefix}1${lst} -i -t -v ${share_file}:/mnt --name=${zk_server}${i} --hostname=${zk_server}${i} ${image_name}
	echo $i > myid
	zk_data=`grep 'dataDir' zoo.cfg.tpl | awk -F '=' '{print $2}'`
	docker cp myid ${zk_server}${i}:${zk_data}/myid
        docker cp ./authorized_keys ${zk_server}${i}:/root/.ssh/authorized_keys
        docker cp zk_start.sh ${zk_server}${i}:/zk_start.sh
	docker cp zk_status.sh ${zk_server}${i}:/zk_status.sh
	docker start ${zk_server}${i}
done

# 删除临时文件
rm -rf ./authorized_keys ./hosts.tmp ./zoo.cfg
